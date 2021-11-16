/* A wrapper for a linker inside the `mipsel` chroot. */
/* Assumes it has permission to chroot. */
#include <spawn.h>
#include <string.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>

extern char** environ;
/* TODO: use a chroot(path) call instead of the chroot command */
int main(int argc, char** argv) {
   if (argc < 2) {
      printf("%s: expected linker arguments\n", argv[0]);
      exit(1);
   }
   /* We need space for adding up to 2 arguments to the front, plus 1 null at the end. */
   /* Ignore the possibility of overflow here, since we assume Cargo to not be malicious. */
   char** child_argv = malloc((argc + 3) * sizeof(char*));
   child_argv[0] = "chroot";
   child_argv[1] = "mipsel/";
   child_argv[2] = "gcc";
   int out_idx = 3;
   /* Skip the 0th argument, since that's the name we were invoked with,
      and we don't care about that. */
   for(int i = 1; i < argc; i++) {
      if (strcmp(argv[i], "-lutil") == 0) {
         child_argv[out_idx++] = "-lc";
      } else {
         child_argv[out_idx++] = argv[i];
      }
   }
   for(; out_idx < argc + 2; out_idx++) child_argv[out_idx] = NULL;
   for(int i = 0; i < argc + 3; i++) {
      printf("child_argv[%d]: %s\n", i, child_argv[i]);
   }
   pid_t child_pid;
   int status;
   status = posix_spawnp(&child_pid, "chroot", NULL, NULL, child_argv, environ);
   /* Check if spawning `chroot` failed. */
   if (status == 0) {
      /* Block on child process exiting. */
      do {
         if (waitpid(child_pid, &status, 0) != -1) {
            return WEXITSTATUS(status);
         } else {
            perror("waitpid");
            exit(1);
         }
      } while(!WIFEXITED(status) && !WIFSIGNALED(status));
   } else {
      printf("posix_spawnp: %s\n", strerror(status));
   }
   return status;
}
