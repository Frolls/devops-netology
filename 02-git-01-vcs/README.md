 ## Описание строк в файле .gitignore
 
1. ***/.terraform/* -- будут проигнорированы вложенные скрытые папки ".terraform" со всем содержимым;
2. *.tfstate -- игнорировать все файлы с расширением "tfstate";
3. *.tfstate.* -- все файлы, содержащие в наименовании строку ".tfstate." не отслеживать и игнорировать;
4. *.tfvars -- игнорировать все файлы с расширением "tfvars";
5. override.tf -- файл "override.tf" должен быть проигнорирован;
6. override.tf.json -- игнорировать файл "override.tf.json";
7. *_override.tf -- все файлы, содержащие строку "_override.tf" в наименовании будут проигнорированы;
8. *_override.tf.json -- все файлы, содержащие в наименовании строку "_override.tf.json" игнорировать;
9. .terraformrc -- игнорировать скрытый файл ".terraformrc"
10. terraform.rc -- файл "terraform.rc" будет проигнорирован