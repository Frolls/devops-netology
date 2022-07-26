# Решение домашнего задания к занятию "7.6. Написание собственных провайдеров для Terraform."

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя?

**Решение**

**Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на гитхабе.**

Как занятно.. 

`resourse` находятся [тут](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L913)

`data_source` лежат [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L415)

**Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.**

- *С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.*
 `name` конфликтует с параметром `name_prefix`. [Строка кода](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L87)
- *Какая максимальная длина имени?* [80 символов](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L427)
- *Какому регулярному выражению должно подчиняться имя?* Вот оно: `^[a-zA-Z0-9_-]{1,80}$`