#!/usr/bin/env python3
#
# This script adds the "-fno-omit-frame-pointer" flag to the configuration of
# every Spack-detected compiler which we know to support it.
#
# FIXME: Bring back the -O3 flag once we can handle it


# This script requires PyYAML, which on openSUSE can be installed via
# `zypper in python3-PyYAML`
import os.path, re, yaml

# Location of the Spack compiler configuration
#
# You should run `spack compiler find` to fill in this configuration before
# running this script.
#
compilers_config_path = os.path.expanduser('~/.spack/linux/compilers.yaml')

# Compilers which are known to support the relevant flags have a spec which
# matches the followign regular expression.
supported_compiler_regex = re.compile('^gcc|clang')

# Load the Spack compiler configuration
compilers_config_file = open(compilers_config_path, mode='r')
compilers_config = yaml.safe_load(compilers_config_file)

# Look at compilers one by one
for compiler_entry in compilers_config['compilers']:
    compiler_config = compiler_entry['compiler']
    # If this compiler is supported...
    if supported_compiler_regex.match(compiler_config['spec']):
        # ...then add the flags to its C/++/Fortran configuration
        compiler_flags_config = compiler_config['flags']
        for flag in ['cflags', 'cxxflags', 'fflags']:
            flag_config = compiler_flags_config.get(flag, '')
            if flag_config != '':
                flag_config += ' '
            flag_config += '-fno-omit-frame-pointer'
            compiler_flags_config[flag] = flag_config

# Overwrite the compiler configuration
compilers_config_file = open(compilers_config_path, mode='w')
yaml.dump(compilers_config, compilers_config_file)