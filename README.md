twitter-reply-bot
--

This bot is basically the ruby port of [twitter-advice-bot](https://github.com/jonjanego/Twitter-Advice-Bot/blob/master/advice_bot.py), which is made in Python.

It has some other features that the Python version doesn't have:

1. Being able to fetch the advices from a remote .json file (stored by you somewhere in the interwebz).
2. Start it in "development" mode, avoiding tweeting real tweets and seeing the output in STDOUT.
3. A nice README.

## Setup

Install:

`$ bundle install`

Run: 

`$ ADVICES_FILE=http://example.com/your_file.json bundle exec ruby bot.rb`

You can additionally pass ENV=development to have the log output to STDOUT instead of a file, use pry and avoid tweets from being actually tweeted.

## Usage:

Point the `advices_url` to wherever your remote .json file is.

The original version uses a hash instead of a remote file, but I find this a bit more useful, allowing people to change the advices without having to restart the bot.

That's it!


# UnLicence

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to [http://unlicense.org](http://unlicense.org/)
