# These libm functions are known to fail under verrou due to range wrapping
__cos_fma       /lib64/libm-2.27.so
__dubsin_fma  /lib64/libm-2.27.so
__ieee754_acos_fma    /lib64/libm-2.27.so
__ieee754_atan2_fma   /lib64/libm-2.27.so
__sin_fma       /lib64/libm-2.27.so
__tan_fma       /lib64/libm-2.27.so
__atan_fma      /lib64/libm-2.27.so
sincos  /lib64/libm-2.27.so

# This libm function also fails in double precision. Unclear why.
__exp1_fma      /lib64/libm-2.27.so

# These libm functions also fail in "float" rounding mode for unclear reasons
__ieee754_exp_fma     /lib64/libm-2.27.so
__fma_fma3            /lib64/libm-2.27.so

# This libm function _segfaults_ under verrou. Bug reported.
__ieee754_pow_fma       /lib64/libm-2.27.so

# This should fail for the same reasons, but it seems we can get away without excluding it for now
# _ZN4Acts6detail13wrap_periodicIdEET_S2_S2_S2_   /root/acts-core/spack-build/Core/libActsCore.so

# These exclusions handle a numerical instability in the setup of SurfaceArrayCreatorTests
_ZN4Acts4Test26SurfaceArrayCreatorFixture17makeBarrelStaggerEiidddd     /root/acts-core/spack-build/Tests/Core/Tools/SurfaceArrayCreatorTests
_ZN4Acts4Test26SurfaceArrayCreatorFixture22fullPhiTestSurfacesBRLEmddddd        /root/acts-core/spack-build/Tests/Core/Tools/SurfaceArrayCreatorTests
_ZN4Acts4Test26SurfaceArrayCreatorFixture21fullPhiTestSurfacesECEmddddd /root/acts-core/spack-build/Tests/Core/Tools/SurfaceArrayCreatorTests

# These exclusions handle a false positive in the conversion of CylinderLayer to variant_data and back
_ZNK4Acts13CylinderLayer13toVariantDataB5cxx11Ev        /root/acts-core/spack-build/Core/libActsCore.so
_ZN4Acts13CylinderLayerC1ERKSt10shared_ptrIKN5Eigen9TransformIdLi3ELi2ELi0EEEERKS1_IKNS_14CylinderBoundsEESt10unique_ptrINS_12SurfaceArrayESt14default_deleteISF_EEdSE_INS_18ApproachDescriptorESG_ISJ_EENS_9LayerTypeE /root/acts-core/spack-build/Core/libActsCore.so

# This is an interesting false-positive. Basically, if we let Verrou instrument this function, then the Navigator can pick a wrong starting volume and get very confused.
_ZNK4Acts11BinningData5valueERKN5Eigen6MatrixIdLi3ELi1ELi0ELi3ELi1EEE   /root/acts-core/spack-build/Tests/Core/Propagator/StepperTests
