# Описание жизненного цикла задачи (разработки нового функционала)

Необходимо описать процесс решения задачи в соответствии с жизненным циклом 
разработки программного обеспечения. 
Использование какого-либо конкретного метода разработки не обязательно. 
Для решения главное - прописать по пунктам шаги решения задачи (релизации в конечный результат) с участием менеджера, 
разработчика (или команды разработчиков), тестировщика (или команды тестировщиков) и себя как DevOps-инженера. 


---

Забавно, что я DevOps в успешном интернет-магазине, а процессы не налажены.. )

Основная моя задача при добавлении функционала -- настройка незаметного внедрения улучшений продукта и непрерывного 
процесса обновления. При этом не стоит забывать про максимизацию эффективности операционных процессов, сокращение 
времени выхода продукта на рынок. 

Шаги решения задачи:
1. Сначала я должен отладить взаимодействие, в том числе внешние интеграции (соглашение о модели взаимодействия, поддержка 
изменений, лицензирование):
   - между заказчиками и менеджерами. Определиться, каким образом менеджеры и заказчики общаются между собой, как
задачи по улучшению/добавлению функционала поступают к нам;
   - между менеджерами. Каждый менеджер отвечает за определенный круг задач. Недопустимо, чтобы каждый занимался 
всем, при этом никто ни за что не был ответственным;
   - между менеджером и разработчиками. Решить, каким образом задачи поступают в работу к разработчикам. Оцениваются 
приоритет, сложность, сроки и тд;
   - между разработчиками. Должны быть общие инструменты, подходы к разработке.
2. Разработка. Здесь мне необходимо:
   - следить, что все разработчики наконец-то используют идентичную среду разработки;
   - донести до разработчиков, что любое изменение должно быть предсказуемым, не влиять на безопасность, быть готовым 
к изменениям в свою очередь;
   - оказывать помощь в освоении новых инструментов;
   - следить, что разработчики пишут тесты (юнит, функциональные, приемочные);
   - проводить код-ревью и быстро получать результаты сложных тестов;
3. Далее, необходимо разобраться с инфраструктурой для создания отказоустойчивого решения:
    - выбрать оптимальное решение;
    - осуществить развертывание нескольких площадок;
    - поломать голову над дальнейшей поддержкой этого хозяйства;
4. Теперь -- тестирование. Задача этапа -- прохождение тестирований (неожиданно, но каждая новая фича или 
изменение должны быть протестированы):
    - проведение в автоматическом режиме тестирование программного продукта;
    - в основную ветку не должен попасть нерабочий код;
    - новый код должен быть покрыт тестами.
5. Выкладка в продакшн. Я отвечаю за то, что:
    - выкладка в продакшн происходит только после успешного прохождения тестов;
    - имеется возможность отката изменений;
    - выкладка и откат изменений происходят автоматически.
6. Мониторинг. Здесь от меня, как devops-нженера, требуется:
    - обеспечить извещение о всех ошибках во время тестирования на стейдже и при работе приложения в продакшене;
    - обеспечить простой доступ к логам всех составляющих системы;
    - осуществить автоматическое оповещение об ошибках.


DevOps не заменяет собой Agile, но совместим с ним, поэтому буду опираться на него.