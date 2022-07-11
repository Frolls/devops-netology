# Решение домашнего задания к занятию "7.2. Облачные провайдеры и синтаксис Terraform"

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов.

AWS предоставляет достаточно много бесплатных ресурсов в первый год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).

1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - AmazonDynamoDBFullAccess
   - AmazonRDSFullAccess
   - CloudWatchFullAccess
   - IAMFullAccess
1. Добавьте переменные окружения
   ```
   export AWS_ACCESS_KEY_ID=(your access key id)
   export AWS_SECRET_ACCESS_KEY=(your secret access key)
   ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс.

В виде результата задания приложите вывод команды `aws configure list`.

**Решение**

1. Создал аккаунт AWS
1. Установил aws-cli
1. Выполнил первичную настройку aws-cli
1. Создал IAM политику. Пользовался WEB-интерфейсом, CLI не трогал
1. Добавил переменные окружения
1. Создал, остановил и удалил EC2-инстанс через WEB-интерфейс

Вывод команды `aws configure list`:

```bash
[frolls@mainframe task1]$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************TJJN shared-credentials-file
secret_key     ****************Gph3 shared-credentials-file
    region                us-west-2      config-file    ~/.aws/config
```

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта.
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
   базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы
   не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

**Решение**

Вот что получилось в итоге:

```bash
[frolls@mainframe devops-netology]$ yc config list
token: IDDQD
cloud-id: b1gkvhe2rk0g1fi0uu3t
folder-id: b1gav9nslcgv47g7gpim
compute-default-zone: ru-central1-a
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


**Решения**

1. **Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?** На ум приходит только Packer.
1. **Ссылку на репозиторий с исходной конфигурацией терраформа.**

**Решение для AWS**

Решение [тут](task2/AWS/)

После выполнения `terraform apply`:

```
account_id = "781641735658"
caller_user_id = "AIDA3L7L2LXVP3JJKUNSL"
instance_ip_addr = "172.16.10.100"
region_name = "us-west-2"
subnet_id = "subnet-0bf8513b2304c6040"
```

**Решение для yc**

Решение [здесь](task2/yc)

После выполнения `terraform apply`:

```
external_ip_address_vm_1 = "62.84.114.72"
internal_ip_address_vm_1 = "192.168.10.26"
```

SSH-подключение через публичный IP по ключу работает прекрасно.