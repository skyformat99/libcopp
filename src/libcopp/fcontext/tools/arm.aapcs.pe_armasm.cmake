# =========== libcopp/src - fcontext : arm - aapcs - pe armmasm =========== 
set(PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}")
set(PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH "${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR}")
file(MAKE_DIRECTORY "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}")
if(CYGWIN)
	execute_process (
        COMMAND cygpath -w "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}" 
		OUTPUT_VARIABLE PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH
    )
	
	execute_process (
        COMMAND cygpath -w "${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR}" 
		OUTPUT_VARIABLE PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH
    )
	
	string(STRIP "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH}" PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH)
	string(STRIP "${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH}" PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH)
endif()
	
if(MSVC)
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH}/jump_arm_aapcs_pe_armasm.asm" "${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH}/make_arm_aapcs_pe_armasm.asm")
	set(MASMFound FALSE)
	enable_language(ASM_MASM)
	if(CMAKE_ASM_MASM_COMPILER_WORKS)
		SET(MASMFound TRUE)
	else()
		EchoWithColor(COLOR RED "-- enable masm failed")
		message(FATAL_ERROR "enable ASM_MASM failed")
	endif(CMAKE_ASM_MASM_COMPILER_WORKS)
else()
	execute_process (
        COMMAND "${LIBCOPP_FCONTEXT_AS_TOOL}" /c /Fo "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH}/${PROJECT_LIBCOPP_FCONTEXT_BIN_NAME_MAKE}" 
		"${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH}/make_arm_aapcs_pe_armasm.asm"
        WORKING_DIRECTORY "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}"
    )
	
	execute_process (
        COMMAND "${LIBCOPP_FCONTEXT_AS_TOOL}" /c /Fo "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR_WINPATH}/${PROJECT_LIBCOPP_FCONTEXT_BIN_NAME_JUMP}" 
		"${PROJECT_LIBCOPP_FCONTEXT_ASM_DIR_WINPATH}/jump_arm_aapcs_pe_armasm.asm"
        WORKING_DIRECTORY "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}"
    )
	
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}/${PROJECT_LIBCOPP_FCONTEXT_BIN_NAME_JUMP}" "${PROJECT_LIBCOPP_FCONTEXT_BIN_DIR}/${PROJECT_LIBCOPP_FCONTEXT_BIN_NAME_MAKE}")
endif()