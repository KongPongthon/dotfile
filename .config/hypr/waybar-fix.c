#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/socket.h>

static ssize_t (*real_write)(int fd, const void *buf, size_t count) = NULL;
static ssize_t (*real_send)(int fd, const void *buf, size_t len, int flags) = NULL;

static void init() {
    if (!real_write) real_write = dlsym(RTLD_NEXT, "write");
    if (!real_send) real_send = dlsym(RTLD_NEXT, "send");
}

static int transform_cmd(const char *buf, size_t len, char *out, size_t out_max) {
    if (len >= 19 && strncmp(buf, "dispatch workspace ", 19) == 0) {
        char ws[64] = {0};
        size_t i = 0;
        const char *p = buf + 19;
        while (*p && *p != '\n' && *p != '\r' && i < 60) {
            ws[i++] = *p++;
        }
        snprintf(out, out_max, "eval hl.dispatch(hl.dsp.focus({ workspace = \"%s\" }))\n", ws);
        return (int)strlen(out);
    }
    if (len >= 40 && strncmp(buf, "dispatch focusworkspaceoncurrentmonitor ", 40) == 0) {
        char ws[64] = {0};
        size_t i = 0;
        const char *p = buf + 40;
        while (*p && *p != '\n' && *p != '\r' && i < 60) {
            ws[i++] = *p++;
        }
        snprintf(out, out_max, "eval hl.dispatch(hl.dsp.focus({ workspace = \"%s\" }))\n", ws);
        return (int)strlen(out);
    }
    return 0;
}

ssize_t write(int fd, const void *buf, size_t count) {
    init();
    char newbuf[512];
    int newlen = transform_cmd((const char*)buf, count, newbuf, sizeof(newbuf));
    if (newlen > 0) {
        return real_write(fd, newbuf, (size_t)newlen);
    }
    return real_write(fd, buf, count);
}

ssize_t send(int fd, const void *buf, size_t len, int flags) {
    init();
    char newbuf[512];
    int newlen = transform_cmd((const char*)buf, len, newbuf, sizeof(newbuf));
    if (newlen > 0) {
        return real_send(fd, newbuf, (size_t)newlen, flags);
    }
    return real_send(fd, buf, len, flags);
}
