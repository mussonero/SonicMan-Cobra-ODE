CELL_MK_DIR = $(CELL_SDK)/samples/mk
include $(CELL_MK_DIR)/sdk.makedef.mk
CELL_INC_DIR = $(CELL_SDK)/target/include

MM	= source/
VIDEO	= video/
FTP	= openftp/
UNZIP = unzip/
SHADERS = shaders/
RELEASE = ./release
BIN	= bin/
NPDRM	= /NPDRM_RELEASE

MM_REL	= MultiSonic
APPID	= BCED01063

MAKE_SELF_WC = make_self_wc

CONTENT_ID=MM4PS3-$(APPID)_00-SONICMANAGER0001

PPU_SRCS = $(MM)graphics.cpp $(MM)language.cpp 
PPU_SRCS += $(VPSHADER_PPU_OBJS) $(FPSHADER_PPU_OBJS) 
PPU_SRCS +=	$(MM)$(VIDEO)vpshader.vp \
		$(MM)$(VIDEO)fpshader.fp \
		$(MM)$(VIDEO)util.c \
		$(MM)$(VIDEO)video.c \
		$(MM)$(VIDEO)common.c \
		$(MM)$(VIDEO)avidmux.c \
		$(MM)$(VIDEO)vdec.c \
		$(MM)$(VIDEO)vpost.c \
		$(MM)$(VIDEO)vdisp.c \
		$(MM)$(VIDEO)adec.c \
		$(MM)$(VIDEO)apost.c \
		$(MM)$(VIDEO)amixer.c \
		$(MM)$(VIDEO)avsync.c

PPU_SRCS +=	$(MM)$(FTP)ftp.c $(MM)$(FTP)ftpcmd.c $(MM)$(FTP)functions.c 

PPU_SRCS +=	$(MM)$(UNZIP)ioapi.c $(MM)$(UNZIP)unzip.c $(MM)$(UNZIP)zip.c $(MM)$(UNZIP)mztools.c

PPU_SRCS += $(MM)multiman.cpp $(MM)manager.cpp $(MM)peek_poke.cpp $(MM)mm.cpp $(MM)hvcall.cpp $(MM)syscall36.cpp $(MM)syscall8.c $(MM)fonts.c $(MM)fonts_render.c $(MM)mscommon.cpp

PPU_LIB_TARGET	=	libunzip.ppu.a

PPU_TARGET = $(MM_REL)_BARE.elf EBOOT.BIN

PPU_OPTIMIZE_LV := -O2 -fno-exceptions

# Disable compiler "warning: format not a string literal, argument types not checked" (not a good idea)
PPU_CPPFLAGS	:= -Wformat=0

PPU_INCDIRS= -Iinclude -I$(CELL_INC_DIR) -I$(CELL_INC_DIR)/usb/usbpad -I$(CELL_INC_DIR)/usb/usbkb -I$(CELL_SDK)/target/ppu/include/sysutil -I$(CELL_SDK)/target/ppu/include -I$(MM)$(UNZIP)
PPU_LDLIBS = -lvpost_stub -lvdec_stub
PPU_LDLIBS += -lfont_stub -lfontFT_stub -lfreetype_stub -lpthread -lmixer -lm -lmstreamSPURSMP3 -ladec_stub -laudio_stub -lnet_stub -lnetctl_stub -lpngdec_stub -ldbgfont_gcm -lgcm_cmd -lgcm_sys_stub -lio_stub -lsysmodule_stub -lsysutil_stub -lfs_stub -lhttp_util_stub  -lspurs_stub -ljpgdec_stub -lhttp_stub -lsysutil_music_export_stub -lsysutil_photo_export_stub -lsysutil_video_export_stub -lrtc_stub -lsysutil_screenshot_stub -lsysutil_np_stub
PPU_LDLIBS += -lusbd_stub


PPU_LDLIBS += -l./libpmsd -l./libpfs -l./libpfsm -l./libz  -l./libunzip.ppu

all : $(PPU_TARGET)
	@scetool --sce-type SELF --compress-data FALSE --self-type APP --key-revision 0004 --self-fw-version 0003004100000000 --self-app-version 0001000000000000 --self-auth-id 1010000001000003 --self-vendor-id  01000002 --self-cap-flags 00000000000000000000000000000000000000000000003b0000000100040000 -e MultiSonic_BARE.elf EBOOT.BIN
	


PPU_CFLAGS  += -g -O2 -fno-exceptions 

VPSHADER_SRCS = vpshader.cg vpshader2.cg
FPSHADER_SRCS = fpshader.cg fpshader2.cg

VPSHADER_PPU_OBJS = $(patsubst %.cg, $(OBJS_DIR)/$(MM)%.ppu.o, $(VPSHADER_SRCS))
FPSHADER_PPU_OBJS = $(patsubst %.cg, $(OBJS_DIR)/$(MM)%.ppu.o, $(FPSHADER_SRCS))

include $(CELL_MK_DIR)/sdk.target.mk

PPU_OBJS += $(VPSHADER_PPU_OBJS) $(FPSHADER_PPU_OBJS)

$(VPSHADER_PPU_OBJS): $(OBJS_DIR)/$(MM)%.ppu.o : %.vpo
	@mkdir -p $(dir $(@))
	@$(PPU_OBJCOPY)  -I binary -O elf64-powerpc-celloslv2 -B powerpc $< $@ > nul

$(FPSHADER_PPU_OBJS): $(OBJS_DIR)/$(MM)%.ppu.o : %.fpo
	@mkdir -p $(dir $(@))
	@$(PPU_OBJCOPY)  -I binary -O elf64-powerpc-celloslv2 -B powerpc $< $@ > nul


pkg : $(PPU_TARGET)
	@mkdir -p $(BIN)
	@$(PPU_STRIP) -s $< -o $(OBJS_DIR)/$(PPU_TARGET)
	@$(MAKE_FSELF_NPDRM) $(PPU_TARGET) $(RELEASE)$(NPDRM)/USRDIR/EBOOT.BIN
	$(MAKE_PACKAGE_NPDRM) $(RELEASE)/package.conf $(RELEASE)$(NPDRM)
