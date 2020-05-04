# Recipes for building Docker images using Spack

## What is this about?

HEP software can be hard to build if you dare deviate from the laptop-hostile
orthodoxy of RHEL / CentOS. But package management systems are here to help.

This project uses a two-layer packaging structure. In the first layer, build
automation is provided by the Spack package manager, which allows you to build
and install HEP software by typing simple commands like
`spack install acts@master +tgeo`. Spack will then take care of figuring out the
missing dependencies and automatically build everything.

Since some HEP software takes a very long time to build, you may also want to
use pre-built packages. For now, these are provided in the form of a stack of
Docker images. In the future, other container systems will be tried out, and if
Spack's support for binary mirrors improves, we will also consider using them.

## Repository structure 

Every folder contains a recipe for building a Docker image using Spack. The
recipes build on top of each other, using the following dependency graph:

     spack
        \________________
         \               \
    root (C++17)       verrou
           \________________
            \               \
       acts (Debug)    acts (RelDeb)
              \
           acts-verrou

The `rebuild-docker-spack.sh` shell script shows how these recipes can be
combined to build the full stack of Spack-based Docker images on the author's
Docker Hub repository ( https://hub.docker.com/r/hgrasland/ ).

Note that this script contains a reference to the target Docker repository, and
will therefore need to be adjusted if you want to rebuild a variant of this
stack on your own repository.

## Why do we need both packages and containers?

In the schematic above, you may notice that the acts-verrou image is unrelated
to the verrou image. This illustrates the lack of composability of Docker's
layered image-building model, which is what motivated the introduction of
Spack packages initially.

Without using Spack, the Verrou build recipe would need to be duplicated between
the verrou and acts+verrou images. As a software stack grows more complex, this
kind of composability issue become omnipresent, and build recipes become
unmaintainable spaghetti code monsters unless a reasoned package management
approach is adopted inside Dockerfile.

Without Spack, it would also be more difficult to tailor software builds to
everyone's individual needs, leading to constant build recipe forks and
rewrites. With Spack, the part that must be forked (Dockerfile) is kept minimal,
as most of the build logic lies in the Spack engine and Spack package recipes.

Furthermore, Docker's focus on isolation from the host system is an imperfect
fit for scientific programming, that gets in the way of using development tools
from the host system and makes some tasks such as interfacing with GPU hardware
or system-wide performance profiling tools needlessly hard. Such tasks may be
much easier to perform locally, which is why having an OS-independent build
recipe handy is very useful.

Why don't we use only Spack, then? Well, first of all, Spack's strong focus on
keeping builds consistent can lead it to frequently rebuild the world in
rapidly-evolving system configurations such as rolling-release Linux
distributions. The very premise of this project is to free people from the
tyranny of indefinitely frozen OS configurations, so bad user experience on
well-updated operating systems would obviously be a major issue.

Another UX issue with Spack is that building some parts of a HEP stack can take
a very long time, which is an unwelcome hindrance for newcomers who just want to
try something out without spending hours staring at a ROOT build. Addressing
their needs require some form of pre-built binary packaging solution.

This proves that combining a package management system that builds from source
code (and therefore, adapts to different system compilers, libraries, and build
option desideratas) with a binary software distribution system is useful.

## Why Spack and Docker specifically?

Spack is one of the main paths that are being explored for HEP packaging
studies. Compared to its main competition...

- It does not inordinately favor a specific Linux/Unix distribution.
- It does not put too much power in the hands of a single company or group.
- It uses Python for package recipes, a language which everyone is familiar
  with and which is reasonably easy to read and write.
- It goes beyond basic versioning and allows significant build customization,
  which is important for software such as ROOT where build options dramatically
  affect which dependent packages can be built.
- It takes great care to preserve the user's environment, allowing peaceful
  coexistence of spack-built packages with each other and with system packages.
- It takes a pragmatic approach to build reproducibility, where reproducibility
  is aimed for by default, but switching to system libraries is not difficult.

Docker is used here as a pragmatic way to work around the Linux distribution
proliferation problem and easily share binary packages from one development
system to another without risking software incompatibilities between different
libc versions, different compiler ABIs, etc.

Arguably, however, Docker does too much isolation for this project, making
use of local system resources unergonomic. So different binary packaging
technologies which focus more on the "ignoring the host libraries" problem and
less on irrelevant concerns such as hiding the host system processes may be
tried in the future.
