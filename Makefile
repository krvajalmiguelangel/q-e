default :
	@echo 'to install, type at the shell prompt:'
	@echo '  ./configure'
	@echo '  make target'
	@echo 'where target is one of the following:'
	@echo '  pw           basic code for scf, structure optimization, MD'
	@echo '  fpmd         FPMD code for Car-Parrinello MD'
	@echo '  cp           CP code: CP MD with ultrasoft pseudopotentials'
	@echo '  ph           phonon code'
	@echo '  pp           postprocessing programs'
	@echo '  gamma        Gamma-only version of phonon code'
	@echo '  pwcond       ballistic conductance'
	@echo '  d3           third-order derivatives'
	@echo '  raman        raman tensor'
	@echo '  tools        misc tools for data analysis'
	@echo '  ld1          utilities for pseudopotential generation'
	@echo '  upf          utilities for pseudopotential conversion'
	@echo '  pwall        same as "make pw ph pp gamma pwcond d3 raman tools"'
	@echo '  all          same as "make pwall fpmd cp ld1 upf"'
	@echo '  clean        remove executables and objects'
	@echo '  veryclean    revert distribution to the original status'
	@echo '  tar          create a tarball of the source tree'
	@echo '  tar-gui      create a tarball of the GUI sources'

pw : bindir mods libs libiotk
	if test -d PW ; then \
	( cd PW ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

fpmd : bindir mods libs libiotk
	if test -d CPV ; then \
	( cd CPV ; if test "$(MAKE)" = "" ; then make $(MFLAGS) fpmd ; \
	else $(MAKE) $(MFLAGS) fpmd ; fi ) ; fi

cp : bindir mods libs libiotk
	if test -d CPV ; then \
	( cd CPV ; if test "$(MAKE)" = "" ; then make $(MFLAGS) cp ; \
	else $(MAKE) $(MFLAGS) cp ; fi ) ; fi

ph : bindir mods libs pw
	if test -d PH ; then \
	( cd PH ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

pp : bindir mods libs pw
	if test -d PP ; then \
	( cd PP ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

gamma : bindir mods libs pw
	if test -d Gamma ; then \
	( cd Gamma ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

pwcond : bindir mods libs pw pp
	if test -d PWCOND ; then \
	( cd PWCOND ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

d3 : bindir mods libs pw ph
	if test -d D3 ; then \
	( cd D3 ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

raman : bindir mods libs pw ph
	if test -d Raman ; then \
	( cd Raman ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

tools : bindir mods libs pw
	if test -d pwtools ; then \
	( cd pwtools ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

ld1 : bindir mods libs pw
	if test -d atomic ; then \
	( cd atomic ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

upf : mods libs
	if test -d upftools ; then \
	( cd upftools ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi ) ; fi

libiotk :
	if test -d iotk ; then \
	( cd iotk ; if test "$(MAKE)" = "" ; then make $(MFLAGS) libiotk.a ; \
	else $(MAKE) $(MFLAGS) libiotk.a ; fi ) ; fi

pw_export : libiotk bindir mods libs pw
	if test -d PP ; then \
	( cd PP ; if test "$(MAKE)" = "" ; then make $(MFLAGS) pw_export.x ; \
	else $(MAKE) $(MFLAGS) pw_export.x ; fi ) ; fi

pwall : pw ph pp gamma pwcond d3 raman tools
all   : pwall fpmd cp ld1 upf 

mods :
	( cd Modules ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi )
libs : mods
	( cd clib ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi )
	( cd flib ; if test "$(MAKE)" = "" ; then make $(MFLAGS) all ; \
	else $(MAKE) $(MFLAGS) all ; fi )
bindir :
	test -d bin || mkdir bin

# remove object files and executables
clean :
	touch make.sys 
	# make complains if they aren't there; same with make.depend below
	for dir in \
		CPV D3 Gamma Modules PH PP PW PWCOND Raman \
		atomic clib flib pwtools upftools iotk \
	; do \
	    if test -d $$dir ; then \
		( cd $$dir ; touch make.depend ; \
		if test "$(MAKE)" = "" ; then make $(MFLAGS) clean ; \
		else $(MAKE) $(MFLAGS) clean ; fi ) \
	    fi \
	done
	- /bin/rm -rf bin/*.x

# remove configuration files too
veryclean : clean
	- /bin/rm -rf make.sys \
		      config.log config.status autom4te.cache \
		      espresso.tar.gz CPV/version.h \
		      intel.pcl */intel.pcl
	- cd examples ; ./make_clean
	- if test -d GUI ; then \
	( cd GUI ; if test "$(MAKE)" = "" ; then make $(MFLAGS) veryclean ; \
		else $(MAKE) $(MFLAGS) veryclean ; fi ) \
	  fi

tar :
	tar cvf espresso.tar \
	    License README* */README* Makefile */Makefile \
	    configure configure.ac config.guess config.sub install-sh \
	    make.sys.in \
	    makedeps.sh moduledep.sh includedep.sh \
	    configure.old \
	    */*.f90 */*.c */*.f clib/*.h include/*.h* upftools/UPF \
	    pwtools/*.awk pwtools/*.sh
	# archive a few entire directories, but without CVS subdirs
	find install Doc atomic_doc examples pseudo -type f \
		| grep -v -e /CVS/ -e /results | xargs tar rvf espresso.tar
	gzip espresso.tar

# TAR-GUI works only if we have CVS-sources !!!
tar-gui :
	@if test -d GUI/PWgui ; then \
	    cd GUI/PWgui ; \
	    if test "$(MAKE)" = "" ; then \
		make $(MFLAGS) clean cvsinit pwgui-source-notcl; \
	    else $(MAKE) $(MFLAGS) clean cvsinit pwgui-source-notcl; fi \
	    mv PWgui-*.tgz ../.. ; \
	else \
	    echo ; \
	    echo "  Sorry, tar-gui works only for CVS-sources !!!" ; \
	    echo ; \
	fi

links : bindir
	( cd bin/ ; \
	for exe in \
	    ../CPV/cp.x \
	    ../D3/d3.x \
	    ../CPV/fpmd.x ../CPV/fpmdpp.x \
	    ../Gamma/phcg.x \
	    ../PH/ph.x \
	    ../PP/average.x ../PP/bands.x ../PP/chdens.x ../PP/dos.x \
	      ../PP/efg.x ../PP/plotband.x ../PP/plotrho.x ../PP/pmw.x \
	      ../PP/pp.x ../PP/projwfc.x ../PP/pw2casino.x ../PP/pw2wan.x \
	      ../PP/voronoy.x ../PP/pw_export.x \
	    ../PW/memory.x ../PW/pw.x \
	    ../PWCOND/pwcond.x \
	    ../Raman/ram.x \
	    ../atomic/ld1.x \
	    ../pwtools/band_plot.x ../pwtools/dist.x ../pwtools/dynmat.x \
	      ../pwtools/ev.x ../pwtools/fqha.x ../pwtools/kpoints.x \
	      ../pwtools/matdyn.x ../pwtools/path_int.x ../pwtools/pwi2xsf.x \
	      ../pwtools/q2r.x \
	; do \
	      if test -f $$exe ; then ln -fs $$exe . ; fi \
	done \
	)
