##--Описание коннектора Облачного Провайдера (в дс. Yandex.Cloud)
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.84.0" # версию необходимо указать только при первичной инициализации Terraform
    }
  }
}

##--Локальные переменные
##
variable "yc_token" { type=string }

locals {
  ## создание токена авторизации (срок жизни: 12 часов)
  ## $ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token
  #
  iam_token        = "${var.yc_token}"                  # iam токен авторизации
  cloud_id         = "b1g0u201bri5ljle0qi2"             # id Облака
  folder_id        = "b1gqi8ai4isl93o0qkuj"             # id Каталога
  access_zone      = "ru-central1-b"                    # зона доступности (размещение ВМ в конкретном датацентре)
  netw_name        = "acme-net"                         # имя Сети к которой будут подключены ВМ
  net_id           = "enpjul7bs1mq29s7m5gf"             # id Сети
  net_sub_name     = "acme-net-sub2"                    # имя Подсети (в одной Сети может быть несколько подСетей)
  net_sub_id       = "e2lbvjotvmelh1nslcrr"             # id Подсети
  ssh_keys_dir     = "/home/devops/.ssh"                # каталог размещения ключевой ssh-пары на локальном хосте
  ssh_pubkey_path  = "/home/devops/.ssh/id_ed25519.pub" # public ssh-ключ для авторизации по ключу на серверах
  ssh_privkey_path = "/home/devops/.ssh/id_ed25519"     # private ssh-ключ для авторизации по ключу на серверах
 #vm1_name         = "host1"                            # отображаемое в списке имя ВМ1
 #vm1_hostname     = "host1"                            # сетевое имя ВМ
 #vm1_ipv4_local   = "10.0.10.13"                       # IPv4-адрес создаваемого локального интерфейса ВМ1
  vm_default_login = "ubuntu"                           # Ubuntu image default username
  vm_disk0id       = "fd8clogg1kull9084s9o"             # используемая версия ОС в качестве загрузочной (id из Yandex Cloud Marketplace)
  vm_disk0size     = 8                                  # выделяемый размер загрузочного диска для ВМ, ГБ (от 8 ГБ, далее зависит от задач)
}

##..авторизация на стороне провайдера и указание Ресурсов с которыми будет работать Terraform
provider "yandex" {
  token     = local.iam_token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = local.access_zone
}

##----------------------------------------------------------------------------------------
##=Создание групп виртуальных машин с ручным/авто масштабированием (Instance Group)
##----------------------------------------------------------------------------------------
## *применяется в сценарии когда необходимо создать множество однотипых ВМ по шаблону
#

##..создаем отдельный сервисный аккаунт (СА) для управления группой (обязательно)
##  *в результате в каталоге "default" облака "cloud-skillfactory" будет создан СА "cloud-skillfactory-ig-sa" с ролью "editor"
resource "yandex_iam_service_account" "ig-sa" {
  name        = "cloud-skillfactory-ig-sa"
  description = "service account to manage Instance Group"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id  = local.folder_id                                             # связываем СА с конкретным каталогом в облаке
  role       = "editor"                                                    # роль/права выданные СА для работы в каталоге
  member     = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"     # сохраняем id СА в виде пары "ключ-значение" (?)
  depends_on = [
    yandex_iam_service_account.ig-sa,                                      # связываем созданный СА с сервисом IAM аккаунтов (?)
  ]
}


##..создаем Группу ВМ (Instance Group)
resource "yandex_compute_instance_group" "ig-1" {
  ##--Базовые параметры
  folder_id           = local.folder_id                                    # cвязывем Группу с Каталогом по id (создаем группу в указанном каталоге)
  name                = "ig-zabbix-fixed"                                  # Базовые параметры - Имя
  description         = "zabbix agents"                                    # Базовые параметры - Описание
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"           # Базовые параметры - Сервисный аккаунт
  deletion_protection = "false"                                            # Базовые параметры - Защита от удаления
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]  # обязательное требование: связь с любым СА с Ролью "editor"

  ##--Шаблон виртуальной машины
  instance_template {
    ##..сетевое имя и имя ВМ в списке (красивые имена вида "hostN", а не уродские как по-умолчанию)
    ##  https://cloud.yandex.ru/docs/compute/concepts/instance-groups/variables-in-the-template
    #
    #name           = "host-{instance.index}"   # host-1 host-2 ..
    name            = "host{instance.index}"     # host1  host2  ..
    hostname        = "host{instance.index}"
    #
    #name           = join("", slice(split(".", "${yandex_compute_instance_group.ig-1.instances.*.network_interface.0.ip_address}"), 2,4))  ## ERROR :: Configuration for yandex_compute_instance_group.ig-1 may not refer to itself.
    #name           = "host-join('', slice(split('.', {instance.ip_address}), 2,4))" ## ERROR  :: - name: Field must contain proper placeholder combination in order to guarantee uniqueness
    #

    ##..выбор платформы и ресурсов
    platform_id     = "standard-v2"             # семейство  облачной платформы ВМ :: Intel Cascade Lake
    resources {
      cores         = 2                         # колво ядер vCPU
      memory        = 1                         # объем RAM, ГБ
      core_fraction = 5                         # доля vCPU, %
    }

    ##..политика управления
    scheduling_policy {
      preemptible = true                    # прерываемая ВМ
    }

    ##--Выбор образа/загрузочного диска
    boot_disk {
      mode = "READ_WRITE"                   # режим работы с диском (Чтение + Запись)
      initialize_params {
        image_id    = local.vm_disk0id      # id образа ОС из "Yandex Cloud Marketplace"
        type        = "network-hdd"
        size        = local.vm_disk0size
        description = "Ubuntu 22.04 LTS"
      }
    }

    ##..конфигурация автоматически создаваемых сетевых интерфейсов
    network_interface {
      #network_id   = "${yandex_vpc_network.network-1.id}"   # id Сети к которой подключаются ВМ
      #subnet_ids   = ["${yandex_vpc_subnet.subnet-1.id}"]   # список id Подсетей по которым могут распределятся создаваемые ВМ
      network_id    = local.net_id
      subnet_ids    = ["${local.net_sub_id}"]
      nat           = true                                   # создавать NAT-интерфейс с публичным динамическим IPv4 адресом
    }

    ##..метаданные содержащие доп. настройки применяемые к ВМ
    metadata = {
      serial-port-enable = 0                                                      # разрешить доступ к серийной консоли :: false
     #ssh-keys = "ubuntu:${file("${local.ssh_pubkey_path}")}"                     # данные авторизации по ssh-ключу: имя_пользователя:содержимое_SSH-ключа
      ssh-keys = "${local.vm_default_login}:${file("${local.ssh_pubkey_path}")}"
    }
  }

  ##--Масштабирование              # Политика масштабирования
  scale_policy {
    fixed_scale {                  # Масштабирование - Тип
      size = 2                     # Масштабирование - Размер (количество ВМ в группе)
    }
  }

  ##--Распределение                # Политика распределения
  allocation_policy {
    #zones = ["ru-central1-b"]     # Распределение - Зона доступности :: ru-central1-a, ru-central1-b, ru-central1-c
    zones = [local.access_zone]
  }

  ##--Развертывание                # Политика развертывания
  deploy_policy {
    max_expansion     = 0          # Развертывание - Добавлять выше целевого значения (макс колво ВМ, на которое можно превысить размер группы)
    max_unavailable   = 1          # Развертывание - Уменьшать относительно целевого значения (макс колво ВМ, на которое можно уменьшить размер группы)
    ##..поля из стейта
    #max_creating     = 0
    #max_deleting     = 0
    #startup_duration = 0,
    #strategy         = "proactive"
  }

  ##..лучше НЕ размещать провиженер выполнения локального кода тут, 
  ##  т.к он будет вызван сразу после создания "Инстанс Группы", но не после создания всех ВМ внутри группы
  ##  в результате чего код внутри блока срабатывает раньше чем создаются ВМ 
  ##  и соотв. до того как Terraform State будет полностью инициализирован
  ##  если провиженер вызвает скрипты которые работают со State, это может вызвать к технологическим ошибкам при выполнении кода скриптов
  ##  т.е. скрипты будут пытаться работать с "null" значениями, вместо конкретных json блоков, приводя к пустому результату выполнения скриптов
  #
  #provisioner "local-exec" {..}

}

##--Ресурсы которые НЕ создаются в облаке, но они нужны для выполнения некоторой логики после создания основных ресурсов
##  *выполнить "terraform init" если ранее "null_resource" не применялся для установки соотв. компонентов Terraform
#
##..ресурс для вызова Провиженеров (инструкции которые что-то делают локально или удаленно на хостах)
resource "null_resource" "nr-1" {
  /*
  ##..копирует файлы (ssh-ключи) на созданную ВМ
  provisioner "file" {
    source      = local.ssh_keys_dir
    destination = "/tmp"
    #..блок параметров ssh-подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host2.network_interface.0.nat_ip_address  ## (!) а вот ТУТ как раз и ОБЛОМ (см. ниже)
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "2m"
    }
  }
  */
  ##(!) ОБЛОМ в том, что этот блок (копирования файлов) нужно выполнять на КАЖДОМ хосте зная его динамический публичный ip адрес, 
  ##    но пример выше требует явного указания ipv4 адреса для подключения конкретно к "host2"
  ##    т.о нам нужно заранее узнать список публичных ipv4 адресов всех созданных хостов чтобы можно было к ним подключиться (в блоке "connection")
  ##    и это в итоге приведет к созданию аналога Ansible/Puppet или других аналогичных систем..
  ##    т.о пока у меня решения нет, кроме как использовать Ansible по схеме:
  ##    - динамически создается Ansible Инвентори (это уже у меня реализовано в "ansible/makeHosts.sh")
  ##    - с помощью Ansible к удаленным хостам применяются Роли (это было реализовано в предыдущих проектах, но в текущем нужно разрабатывать новые Роли)
  ##    **однако все это (ОПЯТЬ) делать НЕ хочется и Лень (двигатель Прогресса) подсказывает что проще было все настроить вручную 
  ##      для выполнения ТЕКУЩЕГО задания (в котором не было цели создания IaC конфига .. который я зачемто сейчас делаю)
  ##    **т.о я решил остановится на текщем результате :: создан IaC конфиг который создает сервисный хост "srv" и хосты по шаблону: "host1", "host2", ..

  ##..выполняет команды на ЛОКАЛЬНОМ хосте на котором применяется Terraform конфигурация
  ##  *задержка выполнения команды требуется для того чтобы она начала выполнятся только после того как будут созданы все инстансы/вм
  ##   решение работающее, но плохое, т.к время задержки нужно указывать вручную (предварительно его определив империческим путем)
  ##   правильным решением было-бы вызов блока после того как пройдет определенная проверка (на наличие ответа от хоста, например)
  provisioner "local-exec" {
    #command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ansible-playbook -i '${yandex_compute_instance.host2.network_interface.0.nat_ip_address},' -u ${local.vm_default_login} ./ansible/deploy_phpfpm.yml"
    command = "sleep 120; ./ansible/makeHosts.sh"
    #
  } ## << "provisioner local-exec"

}

##..ресурс для вызова провиженера выполняющего команды на УДАЛЕННОМ хосте (если выполняется скрипт, то его нужно сначала скопировать на удаленный хост)
##  *не стал создавать кучу "null"-ресурсов, а запихал все провиженеры в один



##--Сетевые настройки
##..Сеть (будем ииспользовать уже существующую Сеть)
/*
resource "yandex_vpc_network" "network1" {
  name = "acme-net"
}
*/

##..Подсети (будем использовать уже существующую Подсеть)
/*
resource "yandex_vpc_subnet" "subnet12" {
  name           = "acme-net-sub2"                        # имя подсети
  zone           = local.access_zone                      # связь подсети с зоной доступности по id
  #network_id    = "${yandex_vpc_network.network-1.id}"   # связь подсети с сетью по id
  network_id     = local.net_id
  v4_cidr_blocks = ["10.0.20.0/24"]                       # адресное IPv4 пространство подсети
}
*/
