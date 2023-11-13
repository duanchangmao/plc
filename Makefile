
TARGET_NAME = target
OS = none
SRC_ROOT = .
SRC_FILES =
INCLUDE_DIR =
USER_LIB_DIR =
USER_LIBS =
USER_LIBS_WHOLE =
USER_LIBS_GROUP =
BUILD_DIR = build
OBJS_DIR = $(BUILD_DIR)/.objs
DEPS_DIR = $(BUILD_DIR)/.deps
LSTS_DIR = $(BUILD_DIR)/.lsts
OBJS = 
OPTIMIZATION_LEVEL = s
DEPENDENCES =
LISTINGS =
MAP =
SPECS =

include $(PROJECT)

ifdef PROJECT
    $(if $(strip $(ARCH)),,$(error ARCH not defined))
    $(if $(strip $(TARGET_TYPE)),,$(error TARGET_TYPE not defined))
    $(if $(strip $(SRC_ROOT)),,$(error SRC_ROOT not defined))
endif

##################################################################
ifeq ($(ARCH),cm3)
    CPU := -mcpu=cortex-m3 -mthumb
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm4)
    CPU := -mcpu=cortex-m4 -mthumb
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm4-sfp)
    CPU := -mcpu=cortex-m4 -mthumb -mfloat-abi=softfp -mfpu=fpv4-sp-d16
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm4-hfp)
    CPU := -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm7)
    CPU := -mcpu=cortex-m7 -mthumb
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm7-sfp)
    CPU := -mcpu=cortex-m7 -mthumb -mfloat-abi=softfp -mfpu=fpv5-d16
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm7-hfp)
    CPU := -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16 -Wa,-mimplicit-it=thumb
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm33)
    CPU := -mcpu=cortex-m33 -mthumb
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),cm33-hfp)
    CPU := -mcpu=cortex-m33 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16
    ifeq ($(OS),none)
        PREFIX = arm-none-eabi-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),x86)
    CPU := -m32
    ifeq ($(OS),linux)
        BUILD_DIR := build/linux-x86
        PREFIX = x86_64-linux-gnu-
    else ifeq ($(OS),win32)
        BUILD_DIR := build/win32-x86
        PREFIX = x86_64-w64-mingw32-
    else
        $(error not support!)
    endif
endif
ifeq ($(ARCH),x86_64)
    CPU := -m64
    ifeq ($(OS),linux)
        BUILD_DIR := build/linux-x86_64
        PREFIX = x86_64-linux-gnu-
    else ifeq ($(OS),win32)
        BUILD_DIR := build/win32-x86_64
        PREFIX = x86_64-w64-mingw32-
    else
        $(error not support!)
    endif
endif
ifdef PROJECT
    $(if $(strip $(CPU)),,$(error unkown CPU))
endif

ifeq ($(TARGET_TYPE),exec)
    ifeq ($(OS),linux)
        EXEC_TARGET := $(BUILD_DIR)/$(TARGET_NAME)
        TARGET := $(EXEC_TARGET)
    else ifeq ($(OS),win32)
        EXEC_TARGET := $(BUILD_DIR)/$(TARGET_NAME).exe
        TARGET := $(EXEC_TARGET)
    else
        EXEC_TARGET := $(BUILD_DIR)/$(TARGET_NAME).elf
        HEX_TARGET := $(BUILD_DIR)/$(TARGET_NAME).hex
        BIN_TARGET := $(BUILD_DIR)/$(TARGET_NAME).bin
        TARGET := $(EXEC_TARGET) $(HEX_TARGET) $(BIN_TARGET)
        $(if $(strip $(LINK_SCRIPT)),,$(error LINK_SCRIPT not defined))
    endif
endif
ifeq ($(TARGET_TYPE),static)
    ifeq ($(OS),none)
        TARGET_NAME := $(TARGET_NAME)-$(ARCH)
    endif
    STATIC_TARGET := $(BUILD_DIR)/lib$(TARGET_NAME).a
    TARGET := $(STATIC_TARGET)
endif
ifeq ($(TARGET_TYPE),shared)
    ifeq ($(OS),linux)
        SHARED_TARGET := $(BUILD_DIR)/$(TARGET_NAME).so
        TARGET := $(SHARED_TARGET)
    else ifeq ($(OS),win32)
        SHARED_TARGET := $(BUILD_DIR)/$(TARGET_NAME).dll
        TARGET := $(SHARED_TARGET)
    else
        $(error not support!)
    endif
endif

CC  = $(PREFIX)gcc
CXX = $(PREFIX)g++
AS  = $(PREFIX)gcc -x assembler-with-cpp
AR  = $(PREFIX)ar
CP  = $(PREFIX)objcopy
SZ  = $(PREFIX)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

INCLUDES +=	$(addprefix -I , $(INCLUDE_DIR))
DEFS  := $(addprefix -D, $(USER_DEFS))
DEFS_ASM := $(addprefix -D, $(USER_DEFS_ASM))

OPT   := -c
ifeq ($(DEBUG_INFO),enable)
OPT   += -g
endif
OPT   += -O$(OPTIMIZATION_LEVEL)
OPT   += -ffunction-sections
OPT   += -fdata-sections
OPT   += -fno-common
OPT   += -Wno-unused-parameter
OPT   += -Wno-unused-variable
OPT   += -Wall

ifeq ($(CREATE_DEPENDENCES),enable)
DEPENDENCES := -MMD -MP -MF"$(patsubst $(SRC_ROOT)/%,$(DEPS_DIR)/%,$(@:%.o=%.d))"
# DEPENDENCES := -MMD -MP -MF"$(addprefix $(DEPS_DIR)/, $(notdir $(@:%.o=%.d)))"
endif

ifeq ($(CREATE_LISTINGS),enable)
LISTINGS := -Wa,-a,-ad,-alms=$(patsubst $(SRC_ROOT)/%,$(LSTS_DIR)/%,$(<:.c=.lst))
# LISTINGS := -Wa,-a,-ad,-alms=$(addprefix $(LSTS_DIR)/, $(notdir $(<:.c=.lst)))
endif

ifeq ($(CREATE_MAP),enable)
MAP := -Wl,-Map=$(BUILD_DIR)/$(TARGET_NAME).map,--cref
endif

# Use newlib-nano.
ifeq ($(USE_NANO),enable)
SPECS += --specs=nano.specs
endif
# Use seimhosting or not
ifeq ($(USE_SEMIHOST),enable)
SPECS += --specs=rdimon.specs
endif
ifeq ($(USE_NOHOST),enable)
SPECS += --specs=nosys.specs
endif

ifeq ($(USE_GARBAGE_COLLECTION),enable)
GC := -Wl,--gc-sections
endif

ifeq ($(GET_GIT_INFO),enable)
DEFS += -DGIT_INFO="$(shell git log --format='%h / %ci %d' -1)"
endif

LIBS := $(addprefix -L, $(USER_LIB_DIR))

ifneq ($(strip $(USER_LIBS)),)
LIBS += $(addprefix -l, $(USER_LIBS))
endif
ifneq ($(strip $(USER_LIBS_WHOLE)),)
LIBS += -Wl,--whole-archive \
        $(addprefix -l, $(USER_LIBS_WHOLE)) \
        -Wl,--no-whole-archive
endif
ifneq ($(strip $(USER_LIBS_GROUP)),)
LIBS += -Wl,--start-group \
        $(addprefix -l, $(USER_LIBS_GROUP)) \
        -Wl,--end-group
endif
# -Wextra
FLAGS_ASM   :=  $(CPU) $(OPT) $(SPECS) $(DEFS_ASM) $(USER_FLAGS_ASM)
FLAGS_C     :=  $(CPU) $(OPT) $(SPECS) $(DEFS) $(USER_FLAGS_C) \
                $(INCLUDES) $(DEPENDENCES) $(LISTINGS) \
                -std=c99 -fverbose-asm
FLAGS_CXX   :=  $(CPU) $(OPT) $(SPECS) $(DEFS) $(USER_FLAGS_CXX) \
                $(INCLUDES) $(DEPENDENCES) $(LISTINGS) \
                -std=c++11 -fverbose-asm -fomit-frame-pointer -fno-rtti \
                -fno-exceptions -fno-threadsafe-statics -fvisibility=hidden
FLAGS_LD    :=  $(CPU) $(SPECS) $(USER_FLAGS_LD) $(GC) $(MAP)
ifdef LINK_SCRIPT
    FLAGS_LD += -T$(LINK_SCRIPT)
endif
ifeq ($(PREFIX), arm-none-eabi-)
    FLAGS_LD += -Xlinker --print-memory-usage
endif

define add_s_file
$(eval S_SRC := $(1)) \
$(eval SOBJ := $(patsubst $(SRC_ROOT)%,$(OBJS_DIR)%,$(addsuffix .o, $(basename $(1))))) \
$(eval OBJS += $(SOBJ)) \
$(if $(strip $(SOBJ)),$(eval $(SOBJ): $(S_SRC)
	@if [ ! -d $$(@D) ]; then mkdir -p $$(@D); fi
	@echo cc $$<
	@$(AS) $$(FLAGS_ASM) -o $$@ $$<))
endef

define add_c_file
$(eval C_SRC := $(1)) \
$(eval COBJ := $(patsubst $(SRC_ROOT)%,$(OBJS_DIR)%,$(addsuffix .o, $(basename $(1))))) \
$(eval OBJS += $(COBJ)) \
$(if $(strip $(COBJ)),$(eval $(COBJ): $(C_SRC)
	@if [ ! -d $$(@D) ]; then mkdir -p $$(@D); fi
	@echo cc $$<
	@$(CC) $$(FLAGS_C) -o $$@ $$<))
endef

define add_cxx_file
$(eval CXX_SRC := $(1)) \
$(eval CXXOBJ := $(patsubst $(SRC_ROOT)%,$(OBJS_DIR)%,$(addsuffix .o, $(basename $(1))))) \
$(eval OBJS += $(CXXOBJ)) \
$(if $(strip $(CXXOBJ)),$(eval $(CXXOBJ): $(CXX_SRC)
	@if [ ! -d $$(@D) ]; then mkdir -p $$(@D); fi
	@echo cc $$<
	@$(CXX) $$(FLAGS_CXX) -o $$@ $$<))
endef

.PHONY: all compile clean

all: $(TARGET)

SRCS := $(strip $(filter %.S,$(SRC_FILES)))
$(if $(SRCS),$(foreach f,$(SRCS),$(call add_s_file,$(f))))
SRCS := $(strip $(filter %.s,$(SRC_FILES)))
$(if $(SRCS),$(foreach f,$(SRCS),$(call add_s_file,$(f))))
SRCS := $(strip $(filter %.c,$(SRC_FILES)))
$(if $(SRCS),$(foreach f,$(SRCS),$(call add_c_file,$(f))))
SRCS := $(strip $(filter %.cpp,$(SRC_FILES)))
$(if $(SRCS),$(foreach f,$(SRCS),$(call add_cxx_file,$(f))))

compile_dir = $(subst $(SRC_ROOT),$(OBJS_DIR),$(subst \,/,$(dir $(FILE))))
$(compile_dir):
	mkdir -p $(compile_dir)
compile: | $(compile_dir)
	$(CC) $(FLAGS_C) -o $(subst $(SRC_ROOT),$(OBJS_DIR),$(FILE:%.c=%.o)) $(FILE)

$(SHARED_TARGET): $(OBJS)
	@echo ------------------------------------------------
	@echo generate $@
	@$(CXX) -fPIC -shared $(FLAGS_LD) $(OBJS) $(LIBS) -o $@
	@-rm -rf $(BUILD_DIR)/.objs

$(STATIC_TARGET): $(OBJS)
	@echo ------------------------------------------------
	@echo generate $@
	@$(AR) -rv $@ $(OBJS)
	@-rm -rf $(BUILD_DIR)/.objs

$(EXEC_TARGET): $(OBJS)
	@echo ------------------------------------------------
	@echo link $@
	@$(CXX) $(FLAGS_LD) $(OBJS) $(LIBS) -o $@
	@echo ------------------------------------------------
	@$(SZ) $@

$(HEX_TARGET): $(EXEC_TARGET)
	@echo ------------------------------------------------
	@echo generate $@
	@$(HEX) $< $@

$(BIN_TARGET): $(EXEC_TARGET)
	@echo ------------------------------------------------
	@echo generate $@
	@$(BIN) $< $@

clean:
	rm -rf $(OBJS_DIR) $(BUILD_DIR)/*
