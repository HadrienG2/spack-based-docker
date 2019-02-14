# Recipes for building Docker images using Spack

## What is this?

HEP software can be hard to build if you dare deviate from the laptop-hostile
orthodoxy of RHEL / CentOS. But package management systems are here to help.

This project uses a two-layer packaging structure. Build automation is provided
by the Spack package manager, which allows you to install HEP software by typing
a mere `spack install gaudi@develop +optional`, letting Spack take care of
figuring out the missing dependencies and building everything.

Since some HEP software takes a very long time to build, you may want to use
pre-built packages. For now, these are provided in the form of a stack of Docker
images. Later on, other container systems may be tried out, and if Spack's
support for binary mirrors improves, we may even be able to use that.

## Repository structure 

Every folder contains a recipe for building a Docker image using Spack. The
recipes build on top of each other, using the following dependency graph:

     spack
        \______________________________
         \               \             \
    root (C++17)    root (C++14)      verrou
           \               \_____________________________
          gaudi             \             \              \
                       acts (Debug)  acts (RelDeb)  acts-framework
                              \
                           acts-verrou

The `rebuild-docker-spack.sh` shell script shows how these recipes can be
combined to build the full stack of Spack-based Docker images on my Docker
Hub repository.

Note that this script and the Dockerfiles' FROM statements will need to be
adjusted to your Docker login if you want to rebuild this stack yourself.

## Why do we need two layers?

In the schematic above, you may notice that the acts-verrou image is unrelated
to the verrou image. This illustrates the lack of composability of Docker's
layered image-building model, which is what motivated the introduction of a
Spack layer initially.

Without using Spack, the Verrou build recipe would need to be duplicated between
the verrou and acts+verrou images. As a software stack grows more complex, this
kind of composability issue become omnipresent, and build recipes become
unmaintainable spaghetti code monsters unless a reasoned package management
approach is adopted inside Dockerfile.

Without Spack, it would also be more difficult to tailor software builds to
everyone's individual needs, leading to constant build recipes forks and
rewrites. With Spack, the part that must be forked (Dockerfile) is kept minimal,
as all the build logic is in the Spack engine and package recipes.

Furthermore, Docker's focus on isolation from the host system is an imperfect
fit for scientific programming, that gets in the way of using development tools
from the host system and makes some tasks such as interfacing with GPU hardware
or system-wide performance profiling tools hacky and error-prone. Local build
are sometimes needed for this reason, and being able to easily take a build
recipe written on a certain OS to another OS is important.

Conversely, using only Spack would cause issues on rolling releases Linux
distributions (where it is desirable to momentarily "freeze" a system
configuration for the sake of not constantly rebuilding everything during a
development study), and frustrate new users who just want to try software out,
without spending hours staring at a ROOT build.

Therefore, combining a package management system that builds from source code
(and therefore, adapts to different system compilers, libraries, and build
option desideratas) with a binary software distribution system is useful.

## Why Spack and Docker?

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
