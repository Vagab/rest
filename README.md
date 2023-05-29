At some point I thought to myself, am I spending too much time writing README-s and code in general?
Perhaps. But that's my job and my life depends on it. So instead of quitting and going on a distant italian
farm to cultivate I decided that I better have a `rest` sometimes. 

And thus this was hallucinated into being.

This package periodically dims your screen for some time so as to forcefully remind the user to have a rest,
unless you were right in the middle of something of course.

# Installation
Only works on macs and can break in a multitude of ways, but in general:
```bash
brew tap vagab/rest
brew install rest
```

# Usage
Run `--help` to see all available options:
```bash
rest -h
# or
rest --help
```
I use it in the following way:
```bash
rest run -r -s 3600 -d 10 -b 0.1
```
Which is going to run the rest in the background and dim your screen to 10% of brightness for 10 seconds
and then wait for an hour before doing so again. To stop the process:
```bash
rest stop
```

# Note
As you might have noticed, I intentionally mantioned
> unless you were right in the middle of something

That is because this sOfTwaRe(really?..) listens to your keystrokes and your mouse moves to determine if it should dim the screen.
Not to worry, it doesn't record anything except the fact that _something_ has happened, not the **what** and only the last
occurence(so not really a **when** either). In any case you can just look through the uglyness which is the source code to ease your mind.
