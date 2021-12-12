## Решения домашнего задания «2.4. Инструменты Git»

Склонировал репозиторий https://github.com/hashicorp/terraform.git

---

#### 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

Неистово захотелось выполнить команду `git show aefea`, выхлоп которой показал:
```
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md


... ну и diff дальше
```

В сухом остатке имеем:
   - полный хеш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545
   - комментарий коммита: Update CHANGELOG.md

#### 2. Какому тегу соответствует коммит `85024d3`?

Аналогично предыдущему пункту, выполняем `git show 85024d3` и бинго!, видим:
```
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
Author: tf-release-bot <terraform@hashicorp.com>
Date:   Thu Mar 5 20:56:10 2020 +0000

    v0.12.23
```

Ответ: коммит `85024d3` соответствует тегу  `v0.12.23`

#### 3. Сколько родителей у коммита `b8d720`? Напишите их хеши.

Просто набрал `git show b8d720` и увидел:

```
commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
Merge: 56cd7859e 9ea88f22f
Author: Chris Griggs <cgriggs@hashicorp.com>
Date:   Tue Jan 21 17:45:48 2020 -0800

    Merge pull request #23916 from hashicorp/cgriggs01-stable
    
    [Cherrypick] community links

```

Это мерж-коммит имеет двух родителей:
   - 56cd7859e (56cd7859e05c36c06b56d013b55a252d0bb7e158) <-- тоже мерж-коммит в свою очередь
   - 9ea88f22f (9ea88f22fc6269854151c571162c5bcf958bee2b)

#### 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами `v0.12.23` и `v0.12.24`

Тут вроде ничего сложного, нужно всего лишь воспользоваться `git log --oneline v0.12.23..v0.12.24` и получить:

```
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
```

#### 5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы)

Здесь уже интереснее..

Для начала найдем, где эта функция вообще используется, воспользовавшись командой `git grep 'func providerSource('`

Получим: `provider_source.go:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
`

Стало понятно, что дальнейшие изыскания нужно проводить в файле `provider_source.go`, чем и займемся командой 
`git log -L :'func providerSource(':provider_source.go`, которая покажет (всё не копипастил):
```
8c928e835 main: Consult local directories as potential mirrors of providers

diff --git a/provider_source.go b/provider_source.go
--- /dev/null
+++ b/provider_source.go
@@ -0,0 +19,5 @@
+func providerSource(services *disco.Disco) getproviders.Source {
+       // We're not yet using the CLI config here because we've not implemented
+       // yet the new configuration constructs to customize provider search
+       // locations. That'll come later.
+       // For now, we have a fixed set of search directories:

```

В итоге, это коммит `8c928e835` ветки `main` с комментарием `Consult local directories as potential mirrors of providers`

Можно воспользоваться `git blame -C -L 23,36 provider_source.go`, который покажет, что это коммит `5af1e6234a`, что неправда:
```
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 23) func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 24)         if len(configs) == 0 {
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 25)                 // If there's no explicit installation configuration then we'll build
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 26)                 // up an implicit one with direct registry installation along with
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 27)                 // some automatically-selected local filesystem mirrors.
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 28)                 return implicitProviderSource(services), nil
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 29)         }
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 30) 
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 31)         // There should only be zero or one configurations, which is checked by
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 32)         // the validation logic in the cliconfig package. Therefore we'll just
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 33)         // ignore any additional configurations in here.
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 34)         config := configs[0]
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 35)         return explicitProviderSource(config, services)
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 36) }

```

#### 6. Найдите все коммиты в которых была изменена функция globalPluginDirs

Сначала найдем, откуда эта функция вообще, выполнив `git grep -p 'func globalPluginDirs('`. 
Это файл `plugins.go`. Далее `git log -L :'func globalPluginDirs(':plugins.go` выдаст нам все коммиты, это:
   - 78b12205587fe839f10d946ea3fdc06719decb05
   - 52dbf94834cb970b510f2fba853a5b49ad9b1a46
   - 41ab0aef7a0fe030e84018973a64135b11abcd70
   - 66ebff90cdfaa6938f26f908c7ebad8d547fea17
   - 8364383c359a6b738a436d1b7745ccdce178df47q

Ах, да.. Можно воспользоваться `git blame -L 18,31 plugins.go`:

```
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 18) func globalPluginDirs() []string {
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 19)         var ret []string
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 20)         // Look in ~/.terraform.d/plugins/ , or its equivalent on non-UNIX
78b1220558 (Pam Selle     2020-01-13 16:50:05 -0500 21)         dir, err := cliconfig.ConfigDir()
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 22)         if err != nil {
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 23)                 log.Printf("[ERROR] Error finding global config directory: %s", err)
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 24)         } else {
41ab0aef7a (James Bardin  2017-08-09 10:34:11 -0400 25)                 machineDir := fmt.Sprintf("%s_%s", runtime.GOOS, runtime.GOARCH)
52dbf94834 (James Bardin  2017-08-09 17:46:49 -0400 26)                 ret = append(ret, filepath.Join(dir, "plugins"))
41ab0aef7a (James Bardin  2017-08-09 10:34:11 -0400 27)                 ret = append(ret, filepath.Join(dir, "plugins", machineDir))
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 28)         }
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 29) 
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 30)         return ret
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 31) }
```

Заятно, что коммита `66ebff90cdfaa6938f26f908c7ebad8d547fea17` здесь нету.. Видимо, промахнулся с номерами строк.

#### 7. Кто автор функции synchronizedWriters?

`git log -S'synchronizedWriters' --oneline` показывает:

```
bdfea50cc remove unused
fd4f7eb0b remove prefixed io
5ac311e2a main: synchronize writes to VT100-faker on Windows
```

Далее `git show 5ac311e2a` и видим:

```
commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Wed May 3 16:25:41 2017 -0700
```
и прочие строки, среди которых искомое
```
...
+func synchronizedWriters(targets ...io.Writer) []io.Writer {
+       mutex := &sync.Mutex{}
+       ret := make([]io.Writer, len(targets))
+       for i, target := range targets {
+               ret[i] = &synchronizedWriter{
+                       Writer: target,
+                       mutex:  mutex,
+               }
+       }
+       return ret
+}

...
```

Итого: автор функции synchronizedWriters -- **Martin Atkins** с интересным почтовым ящиком )