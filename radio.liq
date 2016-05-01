#!/usr/local/bin/liquidsoap

set("log.file.path","/usr/local/var/log/liquidsoap/radio.log")
set("init.daemon",true)
set("log.stdout",true)
set("log.level",3)
set("log.file",true)
%include "library.liq"
set("server.telnet",true)
set("server.telnet.bind_addr","0.0.0.0")

# The file source
night = playlist(reload = 1800, "/home/music/01-09")
morning = playlist(reload = 1800, "/home/music/09-12")
day = playlist(reload = 1800, "/home/music/12-17")
evening = playlist(reload = 1800, "/home/music/17-19")
latening = playlist(reload = 1800, "/home/music/19-01")

# Promo source
promo = playlist(reload = 5000, mode = "random", "/home/music/New")
timed_promo = delay(1200.,promo)

# The jingle source
jingles = playlist(reload = 5000, "/home/music/jingles/")

# The main fallback
default = single("/home/music/stepping.mp3")

s = fallback([
	switch([
        ({ 1h-9h }, night),
		({ 9h-12h }, morning),
		({ 12h-17h }, day),
		({ 17h-19h }, evening),
		({ 19h-1h }, latening)]),
        timed_promo,
        default
])

s = random(weights=[1,5],[ jingles, s ])

s = map_metadata(add_replaygain,s)

s = amplify(override="replay_gain",1.,s)

s = my_crossfade(s)

s = map_metadata(update_title,s)

s = on_metadata(apply_metadata,s)

# A special source
special = request.queue(id="special")
# Smooth_add the special source
s = smooth_add(normal=s,special=special)

s = my_safe(s)

outputs(s)
