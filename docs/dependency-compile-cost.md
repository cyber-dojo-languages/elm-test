# What a test run spends its time on

Measured on an arm64 host, running `cyber-dojo.sh` in a fresh container each
time, which is what a learner waits for: every test run gets a new container,
so nothing a previous run compiled is still there.

## Before the cache: ten seconds a test run

Six runs of the shipped kata, as exit-status/milliseconds:

    0/10350 0/10332 0/10338 0/10343 0/10350 0/10343

Split into stages inside one container:

    node startup             17ms
    elm make src           5070ms      <- first time
    elm make src again       64ms
    elm-test               5294ms      <- first time
    elm-test again          100ms

So nearly all of it is compiling the eight packages `elm.json` names, and it is
paid twice: once by the type-check in `cyber-dojo.sh`, and once by elm-test
inside the project it generates, the two keeping their results in separate
places.

Elm does cache that work, in `elm-stuff` beside the project, which is why the
second run of each is fast. A kata's `elm-stuff` goes with the container it was
made in, so on its own that cache can never pay: this is the case
`_quality_readme.md` describes, where the only place a saving could live is the
container and so there is no saving to be had. What is left is to put it in the
image, which is what `docker/cache_compiled_dependencies.sh` does.

## After the cache: a fifth of a second

Six runs of each of the three lights run_tests.sh drives:

    red     2/225 2/252 2/201 2/226 2/190 2/199
    amber   1/80  1/85  1/83  1/82  1/84  1/81
    green   0/190 0/213 0/199 0/211 0/197 0/213

Restoring the cache costs about 50ms of that, and the type-check then takes
about 17ms rather than 5070ms.

## Three things that stopped the cache working

Each one looked like proof the idea was wrong, because elm says nothing at all
when it decides to ignore the cache: it just quietly does the work again, and a
broken cache is indistinguishable from a pointless one.

- **Elm keys the whole dependency phase on `elm.json`'s modification time, not
  on its contents.** Touching `elm.json` without changing a character of it
  costs the full five seconds again, while editing a source file costs nothing.
  Any copy that does not carry that timestamp across is a cache nothing reads.

- **That timestamp is recorded to finer than a second, and the tools that carry
  it are not.** `cp -p` and `touch -r` work in whole seconds, so the time the
  build recorded was one no kata could ever present, and every run paid in full
  while looking like it had a cache. Pinning `elm.json` to a whole second
  before compiling is what makes the recorded time reproducible. elm-test's
  generated project has its own `elm.json` and needs the same treatment; it
  leaves that file alone once it exists, so pinning it and running elm-test
  once more is what gets the pinned time recorded.

- **Elm records the absolute path of every source file it compiled, and gives
  up on the cache when one of them is not there to look at.** So the warmup
  project is compiled in `/sandbox`, the directory a kata runs in. Compiled
  anywhere else, every recorded path is one no kata will ever have.

Only the compiled packages are reused. A module the learner writes is compiled
again on every test run, so no edit of theirs can ever be answered from the
cache, and the copy is taken only when their `elm.json` is character for
character the one the packages were compiled from.

## One worker, not one per processor

`elm-test` defaults to a worker per processor, and on a ten-processor host each
worker reports a run-stopping error separately. A single `Debug.todo` produced
241 lines, the same node stack ten times over, all of it inside elm-test's own
generated JavaScript. With `--workers 1` the same kata produces 5 lines, naming
the learner's module and the line in it. It is also faster for a kata this
size: about 91ms against about 142ms, there being far fewer node processes to
start than there is work to share out.
