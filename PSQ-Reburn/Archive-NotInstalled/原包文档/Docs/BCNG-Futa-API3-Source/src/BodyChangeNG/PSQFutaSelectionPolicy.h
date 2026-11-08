#pragma once
#include "BodyChangeNG/ActorState.h"
namespace bcn::psq_futa {
inline int Mode(const FutanariFeatureState& s) {
    if (s.useDefault) return s.manual ? 3 : 4;
    if (!s.selectedSkinId.empty()) return s.manual ? 2 : 1;
    return 0;
}
inline bool Assign(FutanariFeatureState& s, std::string id, int mode,
    bool compare = false, std::string_view expected = {}, int expectedMode = 0) {
    if (mode < 0 || mode > 4 || ((mode == 1 || mode == 2) && id.empty()) ||
        ((mode == 0 || mode == 3 || mode == 4) && !id.empty())) return false;
    if (compare && (Mode(s) != expectedMode || !asset_identity::Equal{}(s.selectedSkinId, expected))) return false;
    s.selectedSkinId = std::move(id);
    s.manual = mode == 2 || mode == 3;
    s.useDefault = mode == 3 || mode == 4;
    return true;
}
}
