#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

PKG_NAME:=musl
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://musl.libc.org/releases/
PKG_HASH:=7a35eae33d5372a7c0da1188de798726f68825513b7ae3ebe97aaaa52114f039
PKG_CPE_ID:=cpe:/a:musl-libc:musl

LIBC_SO_VERSION:=$(PKG_VERSION)
PATCH_DIR:=$(PATH_PREFIX)/patches

BUILD_DIR_HOST:=$(BUILD_DIR_TOOLCHAIN)
HOST_BUILD_PREFIX:=$(TOOLCHAIN_DIR)
HOST_BUILD_DIR:=$(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/hardening.mk

TARGET_CFLAGS:= $(filter-out -O%,$(TARGET_CFLAGS))
TARGET_CFLAGS+= $(if $(CONFIG_MUSL_DISABLE_CRYPT_SIZE_HACK),,-DCRYPT_SIZE_HACK)

MUSL_CONFIGURE:= \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	$(HOST_BUILD_DIR)/configure \
		--prefix=/ \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-gcc-wrapper \
		--disable-debug \
		--enable-optimize

define Host/Configure
	ln -snf $(PKG_NAME)-$(PKG_VERSION) $(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
	( cd $(HOST_BUILD_DIR); rm -f config.cache; \
		$(MUSL_CONFIGURE) \
	);
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME) \
		$(BUILD_DIR_TOOLCHAIN)/$(LIBC)-dev
endef
