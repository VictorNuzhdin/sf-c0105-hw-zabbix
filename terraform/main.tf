##--Описание коннектора Облачного Провайдера (в дс. Yandex.Cloud)
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.84.0" # версию необходимо указать только при первичной инициализации Terraform
    }
  }
}

##--Локальные переменные:
##  *iam токен авторизации;
##  *id Облака;
##  *id Каталога;
##  *зона доступности;
##  *public ssh-ключ для авторизации по ключу на серверах;
##
variable "yc_token" { type=string }

locals {
  ## token-created: 2023.04.20 10:00 (срок жизни: 12 часов)
  ## $ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token
  #
  iam_token        = "${var.yc_token}"
  cloud_id         = "b1g0u201bri5ljle0qi2"
  folder_id        = "b1gqi8ai4isl93o0qkuj"
  access_zone      = "ru-central1-b"                    # зона доступности (размещение ВМ в конкретном датацентре);
  netw_name        = "acme-net"
  net_id           = "enpjul7bs1mq29s7m5gf"
  net_sub_name     = "acme-net-sub1"
  net_sub_id       = "e2lcqv479p4bicmd33i1"
  vm_default_login = "ubuntu"                           # Ubuntu image default username;
  ssh_keys_dir     = "/home/devops/.ssh"                # Каталог размещения ключевой ssh-пары на локальном хосте
  ssh_pubkey_path  = "/home/devops/.ssh/id_ed25519.pub"
  ssh_privkey_path = "/home/devops/.ssh/id_ed25519"
  vm1_name         = "srv"                              # отображаемое в списке имя ВМ1
  vm1_hostname     = "srv"                              # сетевое имя ВМ1
  vm1_ipv4_local   = "10.0.10.13"                       # IPv4-адрес создаваемого локального интерфейса ВМ1
  vm1_disk0size    = 8                                  # Выделяемый размер загрузочного диска для ВМ1, ГБ (от 8 ГБ, далее зависит от задач)
}

##--Авторизация на стороне провайдера и указание Ресурсов с которыми будет работать Terraform
provider "yandex" {
  token     = local.iam_token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = local.access_zone
}

##----------------------------------------------------------------------------------------
##--Создаем VM1 (Ubuntu 22.04, x2 vCPU, x2 GB RAM, x8 GB HDD) -- Управляющий хост/сервер
resource "yandex_compute_instance" "host1" {
  name        = local.vm1_name
  hostname    = local.vm1_hostname
  platform_id = "standard-v2"       # семейство облачной платформы ВМ (влияет на тип и параметры доступного для выбора CPU);
  zone        = local.access_zone

  ## Конфигурация виртуальных CPU и RAM
  resources {
    cores         = 2 # колво виртуальных ядер vCPU;
    memory        = 2 # размер оперативной памяти, ГБ;
    core_fraction = 5 # % гарантированной доли CPU (самый дешевый вариант, при 100% вся процессорная мощность резервируется для клиента);
  }

  ## Конфигурация технического обслуживания по расписанию
  scheduling_policy {
    preemptible = true  # делаем ВМ прерываемой (ВМ становится дешевле на 50%, но ее в любой момент могут вырубить что происходит не часто)
  }

  ## Конфигурация загрузочного диска (включает образ на основе которого создается ВМ (из Yandex.Cloud Marketplace)
  boot_disk {
    initialize_params {
      image_id    = "fd8clogg1kull9084s9o"    # версия ОС: Ubuntu 22.04 LTS (family_id: ubuntu-2204-lts, image_id: fd8clogg1kull9084s9o);
      type        = "network-hdd"             # тип загрузочного носителя (network-hdd | network-ssd);
      #size       = 8                         # размер диска, ГБ (меньше 8 ГБ для образа "Ubuntu 22.04" выбрать нельзя)
      size        = local.vm1_disk0size
      description = "Ubuntu 22.04 LTS"
    }
  }

  ## Конфигурация сетевого интерфейса
  network_interface {
    #subnet_id  = yandex_vpc_subnet.subnet1.id  # идентификатор подсети в которую будет смотреть интерфейс;
    subnet_id   = local.net_sub_id              # подключаемся к уже существующей подсети
    #ip_address = "10.0.10.13"                  # указываем явно какой внутренний IPv4 адрес назначить ВМ: последний адрес в диапазоне подсети 10.0.10.0/28;
    ip_address  = local.vm1_ipv4_local
    nat         = true                          # создаем интерфейс смотрящий в публичную сеть;
  }

  ## Конфигурация авторизации пользователей на создаваемой ВМ
  metadata = {
    serial-port-enable = 0                                     # активация серийной консоли чтоб можно было подключиться к ВМ через веб-интерфейс (0, 1);
    ssh-keys = "ubuntu:${file("${local.ssh_pubkey_path}")}"    # передаем публичный ssh ключ который будет добавлен на ВМ в /home/ubuntu/.ssh/authorized_keys
    #ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  ## Копирование файлов #1
  ## Копируем каталог с ssh-ключами из локального хоста на создаваемую ВМ (для дальнейшего создания учетной записи "devops")
  provisioner "file" {
    source      = local.ssh_keys_dir                # "/home/devops/.ssh/"
    destination = "/tmp"

    #..блок параметров подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)    # file("/home/devops/.ssh/id_ed25519")
      timeout = "3m"
    }
  }

  ## Копирование файлов #2
  ## Копируем шелл-скрипт из локального хоста на создаваемую ВМ
  provisioner "file" {
    #..копируем скрипты и конфигурационнае файлы на целевую ВМ1 (ВАЖНО: путь содержит имя Хоста)
    source      = "scripts/srv"
    destination = "/home/ubuntu/scripts/"

    #..блок параметров подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }
  }

  ## Выполнение команд на целевой ВМ после того как ВМ будет создана
  ## *выполняем шелл мастер-скрипт который будет запускать другие конфигурационные шелл-скрипты
  provisioner "remote-exec" {
    #..блок параметров подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }
    ##..блок выполнения команд (1 команда выполняется за ssh 1 подключение)
    inline = [
      "chmod +x /home/ubuntu/scripts/configure_00-main.sh",
      "/home/ubuntu/scripts/configure_00-main.sh"
    ]

  } ## << "provisioner remote-exec"

  ##--Мои комментарии насчет применения Ansible для настройки серверов:
  ##  - т.к Ansible реализует свой способ описания конфигураций настраиваемоего хоста на основе yaml конфигурациии и собственного языка,
  ##    это приводит к тому, что появляется дополнительный слой абстракции (и сложности) от которого можно избавится применяя обычные шелл-скрипты
  ##    которые, на мой взгляд, более читабельные и понятные чем Ansible yaml конфигурации
  ##  - тем не менее, использование Ansible будет скорее всего обосновано когда нужно настраивать множество групп хостов с разными конфигурациями
  ##    и в этом сценарии применение обычных шелл-скриптов было-бы затруднено необходимостью создания их копий с различными изменениями логики настройки хоста
  ##  - при настройке однотипных хостов или небольших групп хостов, я считаю что применение Ansible не целесообразно (поэтому в данном проекте я не применяю Ansible)
  ##
  #provisioner "local-exec" {
  #  ##--Применяем Ansible Плейбук "nginx" к инстансу "host1"
  #  ##  example: ansible-playbook -i 84.252.139.210, -u ubuntu -e host_public_ip_phpfpm=158.160.28.188 ./ansible/deploy_nginx.yml
  #  command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ansible-playbook -i '${yandex_compute_instance.host1.network_interface.0.nat_ip_address},' -u ${local.vm_default_login} -e host_public_ip_phpfpm=${yandex_compute_instance.host2.network_interface.0.nat_ip_address} ./ansible/deploy_nginx.yml"
  #  #
  #} ## << "provisioner local-exec"

}



##--В Сервисе "Virtual Private Cloud" (vpc) Создаем Сеть "acme-net" и подсеть "acme-net-sub1"
##  *если в облаке уже существует такая сеть созданная ранее, то возникнет ошибка изза превышения квоты на кол-во сетей (не более 2х включая "default" сеть)
##      rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
##  *такая сеть уже была создана ранее в предыдущем проекте, поэтому ее создание НЕ требуется и блок закомментирован
#
#resource "yandex_vpc_network" "net1" {
#  name = "acme-net" # имя сети так она будет отображаться в веб-консоли (чуть выше "net1" - это псевдоним ресурса);
#}
#
## *тоже самое это относится и к подсети :: подсеть уже была создана ранее в предыдущем проекте, поэтому ее создание НЕ требуется и блок закомментирован
#resource "yandex_vpc_subnet" "subnet1" {
#  name           = "acme-net-sub1"              # имя подсети;
#  zone           = local.access_zone            # зона доступности (из локальной переменной);
#  network_id     = yandex_vpc_network.net1.id   # связь подсети с сетью по id (net1 - это созданный псевдоним Ресурса);
#  v4_cidr_blocks = ["10.0.10.0/28"]             # адресное IPv4 пространство подсети;
#}
## *ПРИМЕЧАНИЕ:
##  - для подключения создаваемой ВМ к уже существующей сети и подсети, необходимо указать ее идентификатор в:
##    network_interface {
##        subnet_id = yandex_vpc_subnet.subnet1.id
##


/*=EXAMPLE_OUTPUT:

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    Outputs:

    vm1_srv_external_ip = "srv: 158.160.78.4"
    vm1_srv_internal_ip = "srv: 10.0.10.13"
*/
