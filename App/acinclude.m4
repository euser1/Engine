
# QL_CHECK_LONG_LONG
# ----------------------------------------------
# Check whether long long is supported.
AC_DEFUN([QL_CHECK_LONG_LONG],
[AC_MSG_CHECKING([long long support])
 AC_TRY_COMPILE(
    [],
    [long long i;
     unsigned long long j;
    ],
    [AC_MSG_RESULT([yes])
     AC_DEFINE([QL_HAVE_LONG_LONG],[],
               [Define this if your compiler supports the long long type.])
    ],
    [AC_MSG_RESULT([no])
    ])
])

# QL_CHECK_ASINH
# ----------------------------------------------
# Check whether the asinh function is defined in cmath.
# It defines QL_HAVE_ASINH if found.
AC_DEFUN([QL_CHECK_ASINH],
[AC_MSG_CHECKING([for asinh])
 AC_TRY_COMPILE(
    [@%:@include<cmath>],
    [double x = asinh(0.0);],
    [AC_MSG_RESULT([yes])
     AC_DEFINE([QL_HAVE_ASINH],[],
               [Define this if your compiler defines asinh in <cmath>.])
    ],
    [AC_MSG_RESULT([no])
    ])
])

# QL_CHECK_BOOST_DEVEL
# --------------------
# Check whether the Boost headers are available
AC_DEFUN([QL_CHECK_BOOST_DEVEL],
[AC_MSG_CHECKING([for Boost development files])
 AC_TRY_COMPILE(
    [@%:@include <boost/version.hpp>
     @%:@include <boost/shared_ptr.hpp>
     @%:@include <boost/assert.hpp>
     @%:@include <boost/current_function.hpp>],
    [],
    [AC_MSG_RESULT([yes])],
    [AC_MSG_RESULT([no])
     AC_MSG_ERROR([Boost development files not found])
    ])
])

# QL_CHECK_BOOST_VERSION
# ----------------------
# Check whether the Boost installation is up to date
AC_DEFUN([QL_CHECK_BOOST_VERSION],
[AC_MSG_CHECKING([for Boost version >= 1.55])
 AC_REQUIRE([QL_CHECK_BOOST_DEVEL])
 AC_TRY_COMPILE(
    [@%:@include <boost/version.hpp>],
    [@%:@if BOOST_VERSION < 105500
     @%:@error too old
     @%:@endif],
    [AC_MSG_RESULT([yes])],
    [AC_MSG_RESULT([no])
     AC_MSG_ERROR([outdated Boost installation])
    ])
])

# QL_CHECK_BOOST_UBLAS
# --------------------
# Check whether the Boost headers are available
AC_DEFUN([QL_CHECK_BOOST_UBLAS],
[AC_MSG_CHECKING([for Boost::uBLAS support])
 AC_TRY_COMPILE(
    [@%:@include <boost/numeric/ublas/vector_proxy.hpp>
     @%:@include <boost/numeric/ublas/triangular.hpp>
     @%:@include <boost/numeric/ublas/lu.hpp>],
    [],
    [AC_MSG_RESULT([yes])],
    [AC_MSG_RESULT([no])
     AC_MSG_WARN([Some functionality will be disabled.])
     AC_DEFINE([QL_NO_UBLAS_SUPPORT],[],
               [Define this if your compiler does not support Boost::uBLAS.])
    ])
])

# QL_CHECK_BOOST_UNIT_TEST
# ------------------------
# Check whether the Boost unit-test framework is available
AC_DEFUN([QL_CHECK_BOOST_UNIT_TEST],
[AC_MSG_CHECKING([for Boost unit-test framework])
 AC_REQUIRE([AC_PROG_CC])
 ql_original_LIBS=$LIBS
 ql_original_CXXFLAGS=$CXXFLAGS
 CC_BASENAME=`basename $CC`
 CC_VERSION=`echo "__GNUC__ __GNUC_MINOR__" | $CC -E -x c - | tail -n 1 | $SED -e "s/ //"`
 for boost_lib in boost_unit_test_framework-$CC_BASENAME$CC_VERSION \
                  boost_unit_test_framework-$CC_BASENAME \
                  boost_unit_test_framework \
                  boost_unit_test_framework-mt-$CC_BASENAME$CC_VERSION \
                  boost_unit_test_framework-$CC_BASENAME$CC_VERSION-mt \
                  boost_unit_test_framework-x$CC_BASENAME$CC_VERSION-mt \
                  boost_unit_test_framework-mt-$CC_BASENAME \
                  boost_unit_test_framework-$CC_BASENAME-mt \
                  boost_unit_test_framework-mt ; do
     LIBS="$ql_original_LIBS -l$boost_lib"
     # 1.33.1 or 1.34 static
     CXXFLAGS="$ql_original_CXXFLAGS"
     boost_unit_found=no
     AC_LINK_IFELSE([AC_LANG_SOURCE(
         [@%:@include <boost/test/unit_test.hpp>
          using namespace boost::unit_test_framework;
          test_suite*
          init_unit_test_suite(int argc, char** argv)
          {
              return (test_suite*) 0;
          }
         ])],
         [boost_unit_found=$boost_lib
          boost_defines=""
          break],
         [])
     # 1.34 shared
     CXXFLAGS="$ql_original_CXXFLAGS -DBOOST_TEST_MAIN -DBOOST_TEST_DYN_LINK"
     boost_unit_found=no
     AC_LINK_IFELSE([AC_LANG_SOURCE(
         [@%:@include <boost/test/unit_test.hpp>
          using namespace boost::unit_test_framework;
          test_suite*
          init_unit_test_suite(int argc, char** argv)
          {
              return (test_suite*) 0;
          }
         ])],
         [boost_unit_found=$boost_lib
          boost_defines="-DBOOST_TEST_DYN_LINK"
          break],
         [])
 done
 LIBS="$ql_original_LIBS"
 CXXFLAGS="$ql_original_CXXFLAGS"
 if test "$boost_unit_found" = no ; then
     AC_MSG_RESULT([no])
     AC_SUBST([BOOST_UNIT_TEST_LIB],[""])
     AC_SUBST([BOOST_UNIT_TEST_MAIN_CXXFLAGS],[""])
     AC_MSG_WARN([Boost unit-test framework not found.])
     AC_MSG_WARN([The test suite will be disabled.])
 else
     AC_MSG_RESULT([yes])
     AC_SUBST([BOOST_UNIT_TEST_LIB],[$boost_lib])
     AC_SUBST([BOOST_UNIT_TEST_MAIN_CXXFLAGS],[$boost_defines])
 fi
])

# QL_CHECK_BOOST_TEST_THREAD_SIGNALS2_SYSTEM
# ------------------------
# Check whether the Boost thread and system is available
AC_DEFUN([QL_CHECK_BOOST_TEST_THREAD_SIGNALS2_SYSTEM],
[AC_MSG_CHECKING([whether Boost thread, signals2 and system are available])
 AC_REQUIRE([AC_PROG_CC])
 ql_original_LIBS=$LIBS
 boost_thread_found=no
 boost_thread_lib="-lboost_thread -lboost_system -lpthread"
 LIBS="$ql_original_LIBS $boost_thread_lib"
 AC_LINK_IFELSE([AC_LANG_SOURCE(
     [@%:@include <boost/thread/locks.hpp>
      @%:@include <boost/thread/recursive_mutex.hpp>
      @%:@include <boost/signals2/signal.hpp>
      
      #ifndef BOOST_THREAD_PLATFORM_PTHREAD
	  #error only pthread is supported on this plattform
	  #endif

      int main() {
        boost::recursive_mutex m;
        boost::lock_guard<boost::recursive_mutex> lock(m);
  
        boost::signals2::signal<void()> sig;
  
        return 0;
	 }
     ])],
     [boost_thread_found=$boost_thread_lib
      break],
     [])
 LIBS="$ql_original_LIBS"
     
 if test "$boost_thread_found" = no ; then
     AC_MSG_RESULT([no])
     AC_SUBST([BOOST_THREAD_LIB],[""])
     AC_MSG_ERROR([Boost thread, signals2 and system libraries not found. 
         These libraries are required by the thread-safe observer pattern.])
 else
     AC_MSG_RESULT([yes])
     AC_SUBST([BOOST_THREAD_LIB],[$boost_thread_lib])
 fi
])
     
])



# QL_CHECK_BOOST_TEST_STREAM
# --------------------------
# Check whether Boost unit-test stream accepts std::fixed
AC_DEFUN([QL_CHECK_BOOST_TEST_STREAM],
[AC_MSG_CHECKING([whether Boost unit-test streams work])
 AC_REQUIRE([AC_PROG_CC])
 AC_TRY_COMPILE(
    [@%:@include <boost/test/unit_test.hpp>
     @%:@include <iomanip>],
    [BOOST_ERROR("foo " << std::fixed << 42.0);],
    [AC_MSG_RESULT([yes])
     AC_SUBST(BOOST_UNIT_TEST_DEFINE,[-DQL_WORKING_BOOST_STREAMS])],
    [AC_MSG_RESULT([no])
     AC_SUBST(BOOST_UNIT_TEST_DEFINE,[""])
    ])
])

# QL_CHECK_BOOST
# ------------------------
# Boost-related tests
AC_DEFUN([QL_CHECK_BOOST],
[AC_REQUIRE([QL_CHECK_BOOST_DEVEL])
 AC_REQUIRE([QL_CHECK_BOOST_VERSION])
 AC_REQUIRE([QL_CHECK_BOOST_UBLAS])
 AC_REQUIRE([QL_CHECK_BOOST_UNIT_TEST])
 AC_REQUIRE([QL_CHECK_BOOST_TEST_STREAM])
])

