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
  #..общие параметры
  iam_token        = "${var.yc_token}"                  # iam токен авторизации
  cloud_id         = "b1g0u201bri5ljle0qi2"             # id Облака
  folder_id        = "b1gqi8ai4isl93o0qkuj"             # id Каталога
  access_zone      = "ru-central1-b"                    # зона доступности (размещение ВМ в конкретном датацентре)
  netw_name        = "acme-net"                         # имя Сети к которой будут подключены ВМ
  net_id           = "enpjul7bs1mq29s7m5gf"             # id Сети
  net_sub_name     = "acme-net-sub2"                    # имя Подсети (в одной Сети может быть несколько подСетей)
  net_sub_id       = "e2lbvjotvmelh1nslcrr"             # id Подсети к которой будет подключена ВМ
  #
  vm_default_login = "ubuntu"                           # Ubuntu image default username
  ssh_keys_dir     = "/home/devops/.ssh"                # каталог размещения ключевой ssh-пары на локальном хосте
  ssh_pubkey_path  = "/home/devops/.ssh/id_ed25519.pub" # public ssh-ключ для авторизации по ключу на ВМ (будет добавлен на ВМ в /home/ubuntu/.ssh/authorized_keys)
  ssh_privkey_path = "/home/devops/.ssh/id_ed25519"     # private ssh-ключ для авторизации по ключу на ВМ (используется в провиженерах при подключении)
  #
  vm_platform      = "standard-v2"
  vm_cores         = 2
  vm_core_fraction = 5
  vm_memory        = 2
  vm_disk0id       = "fd8clogg1kull9084s9o"             # используемая версия ОС в качестве загрузочной (id из Yandex Cloud Marketplace)
  vm_disk0size     = 8                                  # выделяемый размер загрузочного диска для ВМ1, ГБ (от 8 ГБ, далее зависит от задач)
  vm_disk0type     = "network-hdd"                      # тип загрузочного носителя (network-hdd | network-ssd)
  vm_serialenabled = 0                                  # активирована или нет серийная консоль для возможности управления ВМ через веб-интерфейс (0|1)
  vm_maydisabled   = true                               # режим обслуживания ВМ при сервисных работах в облаке - может или нет быть отключена принудительно
  vm_nat_mode      = true                               # включен или выключен NAT интерфейс для которого создается публичный ipv4 адрес и режим его работы
  #..частные параметры
  vm1_name         = "host1"                            # отображаемое в списке имя ВМ1
  vm1_hostname     = "host1"                            # сетевое имя ВМ1
  vm1_ipv4_local   = "10.0.20.3"                        # IPv4-адрес создаваемого локального интерфейса ВМ1 (1 и 2 адреса в диапазоне ЗАРЕЗЕРВИРОВАНЫ под Шлюз и DNS-сервер)
  vm2_name         = "host2"
  vm2_hostname     = "host2"
  vm2_ipv4_local   = "10.0.20.4"
  vm3_name         = "host3"
  vm3_hostname     = "host3"
  vm3_ipv4_local   = "10.0.20.5"
}
##--Yandex Cloud Marketplace
##  Ubuntu 22.04 LTS (family_id: ubuntu-2204-lts, image_id: fd8clogg1kull9084s9o);

##--Авторизация на стороне провайдера и указание Ресурсов с которыми будет работать Terraform
provider "yandex" {
  token           = local.iam_token
  cloud_id        = local.cloud_id
  folder_id       = local.folder_id
  zone            = local.access_zone
}

##----------------------------------------------------------------------------------------
##--Создаем VM1 -- Управляемый хост
resource "yandex_compute_instance" "host1" {  # host1
  name            = local.vm1_name            # vm1
  hostname        = local.vm1_hostname        # vm1
  zone            = local.access_zone
  platform_id     = local.vm_platform

  ## Конфигурация виртуальных CPU и RAM
  resources {
    cores         = local.vm_cores
    core_fraction = local.vm_core_fraction
    memory        = local.vm_memory
  }

  ## Конфигурация технического обслуживания по расписанию
  scheduling_policy {
    preemptible   = local.vm_maydisabled
  }

  ## Конфигурация загрузочного диска (включает образ на основе которого создается ВМ (из Yandex.Cloud Marketplace)
  boot_disk {
    initialize_params {
      image_id    = local.vm_disk0id
      type        = local.vm_disk0type
      size        = local.vm_disk0size
    }
  }

  ## Конфигурация сетевого интерфейса
  network_interface {
    subnet_id     = local.net_sub_id
    ip_address    = local.vm1_ipv4_local      # vm1
    nat           = local.vm_nat_mode
  }

  ## Конфигурация авторизации пользователей на создаваемой ВМ
  metadata = {
    serial-port-enable = local.vm_serialenabled
    ssh-keys = "${local.vm_default_login}:${file("${local.ssh_pubkey_path}")}"
  }

  ## Копирование файлов #1 :: копируем каталог с ssh-ключами из локального хоста на создаваемую ВМ
  ## *для дальнейшего создания учетной записи "devops" с этим ключом
  provisioner "file" {
    source      = local.ssh_keys_dir
    destination = "/tmp"

    #..блок параметров подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = local.vm_default_login
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "3m"
    }
  }

  ## Копирование файлов #2
  ## Копируем шелл-скрипт из локального хоста на создаваемую ВМ
  provisioner "file" {
    #..копируем скрипты и конфигурационнае файлы на целевую ВМ1 (ВАЖНО: путь содержит имя Хоста)
    source      = "scripts/host"
    destination = "/home/ubuntu/scripts/"

    #..блок параметров подключения к ВМ (обязательный)
    connection {
      type = "ssh"
      user = local.vm_default_login
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
      user = local.vm_default_login
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
} ## << "yandex_compute_instance"


##----------------------------------------------------------------------------------------
##--Создаем VM2 -- Управляемый хост
resource "yandex_compute_instance" "host2" {  # host2
  name            = local.vm2_name            # vm2
  hostname        = local.vm2_hostname        # vm2
  zone            = local.access_zone
  platform_id     = local.vm_platform

  resources {
    cores         = local.vm_cores
    core_fraction = local.vm_core_fraction
    memory        = local.vm_memory
  }

  scheduling_policy {
    preemptible   = local.vm_maydisabled
  }

  boot_disk {
    initialize_params {
      image_id    = local.vm_disk0id
      type        = local.vm_disk0type
      size        = local.vm_disk0size
    }
  }

  network_interface {
    subnet_id     = local.net_sub_id
    ip_address    = local.vm2_ipv4_local      # vm2
    nat           = local.vm_nat_mode
  }

  metadata = {
    serial-port-enable = local.vm_serialenabled
    ssh-keys = "${local.vm_default_login}:${file("${local.ssh_pubkey_path}")}"
  }

  ##..copying ssh-keys to remote host..
  provisioner "file" {
    source      = local.ssh_keys_dir
    destination = "/tmp"

    connection {
      type = "ssh"
      user = local.vm_default_login
      host = yandex_compute_instance.host2.network_interface.0.nat_ip_address  # host2
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "3m"
    }
  }

  ##..copying scripts & configs to remote host..
  provisioner "file" {
    source      = "scripts/host"
    destination = "/home/ubuntu/scripts/"

    connection {
      type = "ssh"
      user = local.vm_default_login
      host = yandex_compute_instance.host2.network_interface.0.nat_ip_address  # host2
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }
  }

  ##..executing master-script on remote host
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = local.vm_default_login
      host = yandex_compute_instance.host2.network_interface.0.nat_ip_address  # host2
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }

    inline = [
      "chmod +x /home/ubuntu/scripts/configure_00-main.sh",
      "/home/ubuntu/scripts/configure_00-main.sh"
    ]
  }

} ## << "yandex_compute_instance"



##--Сети и подсети
##..в Сервисе "Virtual Private Cloud" (vpc) ранее была Создана Сеть "acme-net" и подсеть "acme-net-sub2"
##  *пересоздавать каждый раз сеть и подсеть не имеет смысла для целей экономии финансовых ресурсов,
##   поэтому текущие создаваемые ВМ будут подключены к этой уже существующей подсети с CIDR ["10.0.10.0/28"]
## 

/*=EXAMPLE_OUTPUT:

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

    Outputs:

    yaml_output = <<EOT
    hosts:
      host1:
        ipv4_internal: "10.0.20.3"
        ipv4_external: "51.250.99.236"
        host_weblink1: "http://51.250.99.236"
        host_weblink2: "http://host1.dotspace.ru"
      host2:
        ipv4_internal: "10.0.20.4"
        ipv4_external: "84.201.176.85"
        host_weblink1: "http://84.201.176.85"
        host_weblink2: "http://host2.dotspace.ru"

    EOT
*/
