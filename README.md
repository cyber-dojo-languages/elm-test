# elm-test

Genuinely fails to build elm-test docker image.
Output you get is as follows. Any help appreciated...

```
Step 1/9 : FROM cyberdojofoundation/elm:0.18.0
 ---> e9c5f5cc242a
Step 2/9 : MAINTAINER Jon Jagger <jon@jaggersoft.com>
 ---> Running in 2e09b5950f80
 ---> a7c7ba7a144f
Removing intermediate container 2e09b5950f80
Step 3/9 : RUN npm install -g elm-test
 ---> Running in b37b695219e2
npm WARN optional dep failed, continuing fsevents@1.1.1
/usr/bin/elm-test -> /usr/lib/node_modules/elm-test/bin/elm-test
elm-test@0.18.4 /usr/lib/node_modules/elm-test
├── find-parent-dir@0.3.0
├── firstline@1.2.1
├── minimist@1.2.0
├── xmlbuilder@8.2.2
├── chalk@1.1.3 (escape-string-regexp@1.0.5, supports-color@2.0.0, ansi-styles@2.2.1, strip-ansi@3.0.1, has-ansi@2.0.0)
├── fs-extra@0.30.0 (path-is-absolute@1.0.1, rimraf@2.6.1, graceful-fs@4.1.11, jsonfile@2.4.0, klaw@1.3.1)
├── glob@7.1.2 (path-is-absolute@1.0.1, inherits@2.0.3, fs.realpath@1.0.0, once@1.4.0, inflight@1.0.6, minimatch@3.0.4)
├── cross-spawn@4.0.0 (lru-cache@4.0.2, which@1.2.14)
├── binstall@1.2.0 (tar@2.2.1, request@2.79.0)
├── chokidar@1.6.0 (path-is-absolute@1.0.1, inherits@2.0.3, async-each@1.0.1, glob-parent@2.0.0, is-glob@2.0.1, is-binary-path@1.0.1, readdirp@2.1.0, anymatch@1.3.0)
├── lodash@4.13.1
└── node-elm-compiler@4.3.2 (temp@0.8.3, find-elm-dependencies@1.0.1, lodash@4.14.2)
 ---> 661a81ca679f
Removing intermediate container b37b695219e2
Step 4/9 : COPY tests/Main.elm /tmp/tests/Main.elm
 ---> 006bdc330a4c
Removing intermediate container 2e53a0064d8f
Step 5/9 : COPY tests/Tests.elm /tmp/tests/Tests.elm
 ---> 21bf5456f9ad
Removing intermediate container e59b68cc96f3
Step 6/9 : COPY tests/elm-package.json /tmp/tests/elm-package.json
 ---> 0d2c1302a168
Removing intermediate container a4bf71668f45
Step 7/9 : WORKDIR /tmp
 ---> 705f6a20de62
Removing intermediate container 763261c5e4b0
Step 8/9 : RUN elm-test
 ---> Running in b429fa14b98a
Starting downloads...

  ● elm-community/lazy-list 1.0.0
  ● elm-community/shrink 2.0.0
  ● elm-community/elm-test 3.1.0
  ● elm-community/json-extra 2.2.0
  ● elm-lang/lazy 2.0.0
  ● elm-lang/html 2.0.0
  ● elm-lang/virtual-dom 2.0.4
  ● elm-lang/core 5.1.1
  ● mgold/elm-random-pcg 4.0.2
  ● rtfeldman/node-test-runner 3.0.0

Packages configured successfully!
Success! Compiled 62 modules.
Successfully generated /dev/null
Downloading binaries from https://dl.bintray.com/elmlang/elm-test/0.18.4/linux-x64.tar.gz
I found multiple modules named 'Test.Runner.Node'.

Module 'Test.Generated.Main496aafb3c4c5cf7d1e284a81de8ccea9' is trying to import it.

Modules with that name were found in the following locations:

    directory /usr/lib/node_modules/elm-test/src/Test/Runner/Node.elm
    package rtfeldman/node-test-runner

Compilation failed for /tmp/elm-stuff/generated-code/elm-community/elm-test/src/Main496aafb3c4c5cf7d1e284a81de8ccea9.elm
```