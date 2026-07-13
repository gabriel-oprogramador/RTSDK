
#include <raylib.h>

#if defined(PLATFORM_WINDOWS) || defined(PLATFORM_LINUX)
int main() {
  InitWindow(800, 600, "Launcher");
  while(!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(DARKPURPLE);
    EndDrawing();
  }
  CloseWindow();
  return 0;
}
#elif defined(PLATFORM_WEB)
#include <emscripten.h>

int main() {
  InitWindow(800, 600, "Launcher");

  auto OnMainLoop = []() {
    BeginDrawing();
    ClearBackground(DARKPURPLE);
    EndDrawing();
  };
  emscripten_set_main_loop(OnMainLoop, 0, true);
  return 0;
}
#endif