# sf-c0105-hw-zabbix
For Skill Factory study project (C01, HW)

<br>


### 01. Общее описание (возможно будет корректироваться)

```bash
Terraform IaC-конфигурация для создания 2х групп виртуальных машин в облаке провайдера Yandex.Cloud:
1. Группа1 :: ВМ на основе Ubuntu 22.04 LTS :: Сервисный хост "srv" на котором должна быть настроена платформа мониторинга "Zabbix"
2. Группа2 :: ВМ на основе Ubuntu 22.04 LTS :: Управляемые хосты которые будут поставлять зашифрованные метрики для "Zabbix" сервера
```

### 02. История изменений (не детальная, сверху - новые)

```bash
0000.00.00 :: В планах:
    1. разработать способ авто-настройки созданных с помощью "Yandex Cloud Instance Goup" хостов
       по возможности не используя "Ansible" а только используя срества Terraform и шел-скрипты
    2. если [1] не получится, то разработать соответсвующие Роли для "Ansible" для настройки Zabbix сервера и агенттов
    3. если [1] и [2] не получится (или это потребует много времени), настроить созданные хосты вручную по ssh

2023.09.21 :: Разработаны и протестированы базовые Terraform конфигурации:
    - конфигурация "terraform" которая создает сервисный хост "srv" (будущий Zabbix сервер)
      *в Terraform этот ресурс описывался в виде одного блока создания конкретной ВМ
      *в результате сервер становится доступен по URL https://srv.dotspace.ru а также по ssh
    - конфигурация "terrafrom_hosts" которая создает управляемые хосты "hostN" (будущие Zabbix агенты)
      *в Terraform эти ресурсы описывались в виде "Instance Group" с возможностью ручного масштабирования (выбора кол-ва содаваемых ВМ)
      *в результате хосты становятся доступны по ssh по соответствующим публичным ipv4 адресам

2023.09.15 :: Начало работы:
    - изучение общей информации о платформе Zabbix
    - разработка базовых Terrafrom конфигураций:
      * конфигурация "terraform" которая создает сервисный хост "srv" который планируется использовать для установки Zabbix сервера
      * конфигурация "terrafrom_hosts" которая создает управляемые хосты "hostN" которые будут выступать в качестве агентов поставки метрик для Zabbix сервера
```

### 03. Порядок работы
```bash
#0 :: генерация IAM токена в переменную окружения для возможности работы Terraform с YandexCloud через API
$ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token

#1 :: создание, проверка, уничтожение сервисного хоста "srv" (Zabbix сервер)
$ cd terraform

$ terraform validate
$ terraform plan
$ terraform apply -auto-approve

        Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
        Outputs:
        vm1_srv_external_ip = "srv: 158.160.75.233"
        vm1_srv_internal_ip = "srv: 10.0.10.13"

#..перед выполнением дальнейших проверок необходимо подождать около 5 минут чтобы ip-адрес сервера реплецировался в глобальную DNS
#
$ ping -c 1 srv.dotspace.ru                                           ## 64 bytes from srv.dotspace.ru (158.160.75.233): icmp_seq=1 ttl=63 time=0.606 ms
$ curl -s https://srv.dotspace.ru | grep title | awk '{$1=$1;print}'  ## <title>Welcome | srv.dotspace.ru</title>

browser: https://srv.dotspace.ru  ## Welcome to [srv.dotspace.ru] (Service-host for DevOPS tasks)

$ terraform destroy -auto-approve

#2 :: создание, проверка, уничтоженние управляемых хостов "hostN" (Zabbix агенты)
$ cd terraform_hosts

$ terraform validate
$ terraform plan
$ terraform apply -auto-approve

        Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

        Outputs:

        ig_hosts_ipv4_public = tolist([
          "158.160.77.104",
          "158.160.78.2",
        ])

$ ping -c1 158.160.77.104
$ ping -c1 158.160.78.2

$ terraform destroy -auto-approve


#3 :: подключение к созданным хостам по ssh
#     *на локальном хосте требуется наличие соотвествующей ключевой пары в /home/devops/.ssh
#     *подключение производится из под учетной записи "devops" для которой настроена ssh авторизация на ВМ
#
#..подключение к Zabbix серверу
$ ssh devops@srv.dotspace.ru
# или
$ ssh devops@srv.dotspace.ru -i /home/devops/.ssh/id_ed25519

#..подключение к Zabbix агентам
$ ssh ubuntu@158.160.77.104 -i /home/devops/.ssh/id_ed25519
$ ssh ubuntu@158.160.78.2 -i /home/devops/.ssh/id_ed25519


#4 :: проверка атоматически созданного Ansible Inventory (hosts файл)
#     *показано только в качестве демонстрации возможностей. Ansible в проекте не применяется
$ ./terraform_hosts/makeHosts.sh
$ cat terraform_hosts/makeHosts.sh

        ## generatedAt: 2023-09-21 09:45:28
        #
        [zabbix_server]
        localhost

        [zabbix_agents]
        158.160.77.104
        158.160.78.2

        [all:vars]
        ansible_ssh_pass=<SET_REMOTE_HOSTS_PASSWORD>

```

### 04. Замечания
```bash
#1
При разработке Terraform конфигурации натолкнулся на проблему:
- если создается "Instance Group" в которой кол-во хостов может динамически меняться и их публичные ipv4 адреса также меняются,
  то не понятно как в провиженерах "file" и "remote-exec" указывать ссылку на nat-интерфейс чтобы получить его ipм4 адрес;
  конструкция вида "host = yandex_compute_instance.host1.network_interface.0.nat_ip_address"
  в данном случае НЕ работает, т.к у нас существует динамический список созданных хостов
  для каждого из которых нужно вызывать провиженеры
- возможно именно поэтому и были созданы системы Ansible/Puppet и аналогичные, которые работают независимо от Terraform с хостами,
  но им для работы нужен некоторый список ip-адресов созданных хостов..
  в терминологии Ansible этот список называется Inventory и он хранится в файле "hosts", при этом все работает по схеме:
  * шаг1 :: Terrafrom создает виртуальные машины, определяет их публичные ipv4 адреса
  * шаг2 :: эти публичные адреса используются для генерации Ansible hosts файла
  * шаг3 :: Ansible использует созданный hosts файл для подключения к хостам по ssh и их настройки (и Terrafrom уже при этом не используется)

```

### 05. Результат работы веб-приложения

Скриншот01: Служебный хост "srv" с которого будет происходить мониторинг и управление (настроен https) <br>
![screen](_screens/step01__letsencrypt__srv-dotspace-ru__1.png?raw=true)
<br>
![screen](_screens/step01__letsencrypt__srv-dotspace-ru__2.png?raw=true)
<br>

Скриншот02: Группа управляемых ВМ (Yandex Cloud - Instance Group) созданная с помощью Terraform <br>
![screen](_screens/step07__terraform__03_instanceGroup_1_review.png?raw=true)
<br>
![screen](_screens/step07__terraform__03_instanceGroup_2_instances.png?raw=true)
<br>

Скриншот03: Список запущеных ВМ в "Yandex Cloud - Compute Cloud" <br>
![screen](_screens/step07__terraform__04_instances.png?raw=true)
<br>

----