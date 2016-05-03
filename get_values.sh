#! /bin/bash

# Dette skriptet henter alle variabler som er av interesse for plotting

get_values() {
	re=$(LC_NUMERIC="en_US.UTF-8" printf %.02f $($1./get_re.awk $1./output))
	dt=$(LC_NUMERIC="en_US.UTF-8" printf %.04f $($1./get_dt.awk $1./output))
	tmax=$(LC_NUMERIC="en_US.UTF-8" printf %.02f $($1./get_tmax.awk $1./output))
	n=$(LC_NUMERIC="en_US.UTF-8" printf %d $($1./get_n.awk $1./output))
	ideal_dt=$(LC_NUMERIC="en_US.UTF-8" printf %.08f $($1./get_ideal_dt.awk $1./output))
	flow=$(LC_NUMERIC="en_US.UTF-8" printf %.02f $($1./get_flow.awk $1./output))
}
