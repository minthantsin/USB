



USING:  kernel alien alien.c-types alien.data accessors alien.accessors layouts
        libusb byte-arrays namespaces math math.parser arrays sequences
        tokyo.utils tools.hexdump prettyprint combinators.short-circuit
        memory vm classes.struct tools.continuations ;

IN: usb.usb-test

SYMBOLS: dev cnt devdes device handle desc usbstring libusb_device_handle ;

: ptr-pass-through ( obj quot -- alien )
  over { [ c-ptr? ] [ ] } 1&& [ drop ] [ call ] if ; inline


: print_device ( libusb_device -- n )
! struct libusb_device_descriptor desc;
! libusb_device_handle *handle = NULL;
! char description[256];
! char string[256];
! int ret;
! uint8_t i;
  dup device set
  libusb_device_descriptor <struct> desc set desc get
  libusb_get_device_descriptor
  [
    cell <byte-array> handle set
    device get handle get libusb_open LIBUSB_SUCCESS?
    [

    ]
    [
      ""
      desc get idVendor>> >hex
      prepend " " append
      desc get idProduct>> >hex
      append
    ] if



    " (" append
    device get libusb_get_bus_number number>string append
    " " append
    device get libusb_get_device_address number>string append
    ")" append

  ]
  [ "failed to get device descriptor" ] if



! ret = libusb_open(dev, &handle);
! if (LIBUSB_SUCCESS == ret) {
!  if (desc.iManufacturer) {
!   ret = libusb_get_string_descriptor_ascii(handle, desc.iManufacturer, string, sizeof(string));
!    if (ret > 0)
!     snprintf(description, sizeof(description), "%s - ", string);
!    else
!     snprintf(description, sizeof(description), "%04X - ",
!      desc.idVendor);
!   }
!   else
!   snprintf(description, sizeof(description), "%04X - ",
!    desc.idVendor);

!   if (desc.iProduct) {
!    ret = libusb_get_string_descriptor_ascii(handle, desc.iProduct, string, sizeof(string));
!    if (ret > 0)
!     snprintf(description + strlen(description), sizeof(description) -
!      strlen(description), "%s", string);
!    else
!     snprintf(description + strlen(description), sizeof(description) -
!      strlen(description), "%04X", desc.idProduct);
!   }
!   else
!    snprintf(description + strlen(description), sizeof(description) -
!     strlen(description), "%04X", desc.idProduct);
!  }
!  else {
!   snprintf(description, sizeof(description), "%04X - %04X",
!    desc.idVendor, desc.idProduct);
!  }

!  printf("%.*sDev (bus %d, device %d): %s\n", level * 2, "                    ",
!   libusb_get_bus_number(dev), libusb_get_device_address(dev), description);

!  if (handle && verbose) {
!   if (desc.iSerialNumber) {
!    ret = libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, string, sizeof(string));
!    if (ret > 0)
!     printf("%.*s  - Serial Number: %s\n", level * 2,
!      "                    ", string);
!   }
!  }

!  for (i = 0; i < desc.bNumConfigurations; i++) {
!   struct libusb_config_descriptor *config;
!   ret = libusb_get_config_descriptor(dev, i, &config);
!   if (LIBUSB_SUCCESS != ret) {
!    printf("  Couldn't retrieve descriptors\n");
!    continue;
!   }

!   print_configuration(config);

!   libusb_free_config_descriptor(config);
!  }

!  if (handle && desc.bcdUSB >= 0x0201) {
!   print_bos(handle);
!  }
! }

! if (handle)
!  libusb_close(handle);

! return 0;
! }
;



: usb-start ( -- )
    f libusb_init
    [
        f
        cell <byte-array> dev set
        dev get
        libusb_get_device_list cnt set
        dev get int deref <alien> cnt get cell * memory>byte-array
        cell_t cast-array >array
        [
          break
          <alien> print_device
          ! libusb_device_descriptor <struct> devdes set devdes get
          ! libusb_get_device_descriptor drop devdes get
        ] map
        dev get malloc-byte-array alien-address >hex
        drop drop
    ] when

    f libusb_exit
    ;




  : usb-test ( -- )
    f libusb_init
    [

      f    ! ctx
      0x067b  ! vid
      0x2305  ! pid
      libusb_open_device_with_vid_pid libusb_device_handle set

      libusb_device_handle get libusb_close

    ] when

    f libusb_exit ;
