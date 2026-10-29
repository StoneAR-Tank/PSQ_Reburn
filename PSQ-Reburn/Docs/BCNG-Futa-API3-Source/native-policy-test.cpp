#include "BodyChangeNG/PSQFutaSelectionPolicy.h"
#include <iostream>
#include <stdexcept>
int main() {
    int checks{};
    const auto check = [&](bool ok) { ++checks; if (!ok) throw std::runtime_error("PSQ futa ownership policy failed"); };
    const std::string ids[]{"", "auto:original", "manual:original", "", ""};
    for (int originalMode = 0; originalMode < 5; ++originalMode) {
        bcn::ActorState actor{};
        actor.body.selection.selectedId = "body untouched";
        actor.skin.selection.selectedId = "skin untouched";
        check(bcn::psq_futa::Assign(actor.futanari, ids[originalMode], originalMode));
        const auto baseline = actor.futanari;
        check(bcn::psq_futa::Assign(actor.futanari, "temporary:psq", 2));
        check(bcn::psq_futa::Assign(actor.futanari, baseline.selectedSkinId, originalMode, true, "TEMPORARY:PSQ", 2));
        check(actor.futanari.selectedSkinId == baseline.selectedSkinId && actor.futanari.manual == baseline.manual && actor.futanari.useDefault == baseline.useDefault);
        check(actor.body.selection.selectedId == "body untouched" && actor.skin.selection.selectedId == "skin untouched");
        check(bcn::psq_futa::Assign(actor.futanari, {}, 3));
        check(bcn::psq_futa::Assign(actor.futanari, baseline.selectedSkinId, originalMode, true, {}, 3));
        check(bcn::psq_futa::Mode(actor.futanari) == originalMode);
        check(bcn::psq_futa::Assign(actor.futanari, "user:new", 2));
        check(!bcn::psq_futa::Assign(actor.futanari, baseline.selectedSkinId, originalMode, true, "temporary:psq", 2));
        check(actor.futanari.selectedSkinId == "user:new" && actor.futanari.manual);
    }
    bcn::FutanariFeatureState a{}, b{};
    check(bcn::psq_futa::Assign(a, "actor-a", 2));
    check(bcn::psq_futa::Assign(b, "actor-b", 2));
    check(bcn::psq_futa::Assign(a, {}, 0, true, "actor-a", 2));
    check(b.selectedSkinId == "actor-b" && b.manual);
    check(!bcn::psq_futa::Assign(b, "nonempty-default", 3));
    check(!bcn::psq_futa::Assign(b, {}, 2));
    check(!bcn::psq_futa::Assign(b, {}, -1));
    check(b.selectedSkinId == "actor-b");
    check(bcn::psq_futa::Assign(a, {}, 0));
    check(bcn::UpdateAutomaticFutanariSelection(a, std::string{"rule:returns"}));
    check(!a.manual && !a.useDefault && a.selectedSkinId == "rule:returns");
    std::cout << "PASS " << checks << " ownership, defaults, manual takeover and channel-isolation checks\n";
}
