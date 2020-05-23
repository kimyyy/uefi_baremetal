#include "serial.hpp"
#include "bootInfo.hpp"
#include "framebuffer.hpp"
#include "psf.hpp"
#include <stdlib.h>

void testnewlib() {
    int hoge = atoi("4");
}

extern "C"
void KernelMain(BootInfo* bootInfo){
    bool map[4] = {true, false, true, false};
    PsfFont::test();
    FrameBuffer fb = FrameBuffer(bootInfo->fb);
    Pallet pallet;
    PsfFont psffont_cyrkoi(PsfVersion::Version2, _binary_resources_CyrKoi_Terminus32x16_psf_start, _binary_resources_CyrKoi_Terminus32x16_psf_end, _binary_resources_CyrKoi_Terminus32x16_psf_size);
    fb.putc("a", Point(100, 100), pallet.white, pallet.black, psffont_cyrkoi);
    char str[20] = "Hello, kernel!";
    for(int i = 0;i < 20 && str[i] != '\0';i++){
        WriteIOPort8(0x3f8, str[i]);
    }
    while(1);
}
