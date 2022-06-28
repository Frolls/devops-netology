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
