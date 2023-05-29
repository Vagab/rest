#include "logger.h"

CGEventFlags lastFlags = 0;

int main(int argc, const char *argv[]) {

    // Create an event tap to retrieve keypresses.
    CGEventMask keyEventMask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventFlagsChanged);
    CFMachPortRef keyEventTap = CGEventTapCreate(
        kCGSessionEventTap, kCGHeadInsertEventTap, 0, keyEventMask, CGEventCallback, NULL
    );
    CGEventMask mouseEventMask = CGEventMaskBit(kCGEventMouseMoved);
    CFMachPortRef mouseEventTap = CGEventTapCreate(
        kCGSessionEventTap, kCGHeadInsertEventTap, 0, mouseEventMask, CGEventCallback, NULL
    );

    // Exit the program if unable to create the event tap.
    if (!keyEventTap || !mouseEventTap) {
        fprintf(stderr, "ERROR: Unable to create event tap.\n");
        exit(1);
    }


    // Create a run loop source and add enable the event tap.
    CFRunLoopSourceRef keyRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyEventTap, 0);
    CFRunLoopSourceRef mouseRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseEventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), keyRunLoopSource, kCFRunLoopCommonModes);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseRunLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(keyEventTap, true);
    CGEventTapEnable(mouseEventTap, true);

    CFRunLoopRun();

    return 0;
}

// The following callback method is invoked on every keypress.
CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    struct utimbuf new_times;

    new_times.actime = time(NULL);  /* set access time to current time */
    new_times.modtime = time(NULL); /* set modification time to current time */

    utime(logfileLocation, &new_times);
    return event;
}
