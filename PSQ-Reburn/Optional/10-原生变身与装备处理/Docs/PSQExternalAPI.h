#pragma once
#include <stdint.h>

// Resolve PSQ_GetExternalAPI with GetProcAddress on the already-loaded PSQAppearance.dll.
// Pass version 1. The borrowed table is valid for the lifetime of the plugin.
// Call read_player on Skyrim's game thread after DataLoaded. controller is the runtime
// FormID of the PSQ quest bearing playersuccubusquestscript. Result: 1 success, 0
// unavailable (including the wrong thread), -1 invalid argument. On failure out is untouched.
typedef struct PSQ_PlayerStateV1 {
    uint32_t size;
    int32_t transformed, changing, busy, owner, load_epoch;
    int32_t body_family;  // 0 standard, 1 UBE, -1 not classified
    float energy, energy_capacity;
} PSQ_PlayerStateV1;
typedef struct PSQ_ExternalV1 {
    uint32_t size, version;
    int32_t (*read_player)(uint32_t controller, PSQ_PlayerStateV1* out);
} PSQ_ExternalV1;
typedef const PSQ_ExternalV1* (*PSQ_GetExternalAPI_fn)(uint32_t version);
