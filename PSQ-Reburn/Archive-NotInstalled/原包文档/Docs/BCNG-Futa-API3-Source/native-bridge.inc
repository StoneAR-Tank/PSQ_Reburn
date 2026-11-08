    bool FutaEligible(RE::Actor* actor) {
        return actor && actor->GetActorBase() &&
            actor->GetActorBase()->GetSex() == RE::SEX::kFemale;
    }
    bool FutaAtlasEligible(RE::Actor* actor) {
        return FutaEligible(actor) && bcn::ResolveActorSkinRace(actor) == bcn::SkinRace::humanoid;
    }
    std::vector<RE::BSFixedString> GetFutanariIds(RE::StaticFunctionTag*, RE::Actor* actor) {
        std::vector<RE::BSFixedString> ids;
        if (!FutaAtlasEligible(actor) || !IsReady(nullptr)) return ids;
        for (const auto& p : *bcn::FutanariSkinProfiles::Get().SharedSnapshot()) {
            if (p.type == bcn::FutanariSkinType::cbbeTrx &&
                bcn::FutanariSkinTypeMatchesActor(p.type, bcn::body_family::ResolveActor(actor)))
                ids.emplace_back(p.id.c_str());
        }
        return ids;
    }
    RE::BSFixedString GetFutanariName(RE::StaticFunctionTag*, RE::BSFixedString id) {
        const auto p = bcn::FutanariSkinProfiles::Get().Find(id.c_str());
        return p ? RE::BSFixedString(p->name.c_str()) : RE::BSFixedString{};
    }
    RE::BSFixedString GetFutanariSelectionId(RE::StaticFunctionTag*, RE::Actor* actor) {
        const auto p = bcn::ActorRegistry::Get().SelectedFutanariSkinId(actor);
        return p ? RE::BSFixedString(p->c_str()) : RE::BSFixedString{};
    }
    std::int32_t GetFutanariSelectionMode(RE::StaticFunctionTag*, RE::Actor* actor) {
        const auto state = bcn::ActorRegistry::Get().Snapshot(actor);
        return state ? bcn::psq_futa::Mode(state->futanari) : 0;
    }
    std::int32_t RequestFutanariSkin(RE::StaticFunctionTag*, RE::Actor* actor, RE::BSFixedString id) {
        if (!FutaEligible(actor) || !IsReady(nullptr) || bcn::Settings::Get().RemovalMode()) return -1;
        const std::string selected = id.c_str();
        if (!selected.empty()) {
            const auto p = bcn::FutanariSkinProfiles::Get().Find(selected);
            if (!FutaAtlasEligible(actor) || !p || p->type != bcn::FutanariSkinType::cbbeTrx) return -2;
        }
        const auto result = selected.empty() ?
            bcn::skin_application::QueueClearFutanari(actor, bcn::skin_application::FutanariSelectionMode::restore) :
            bcn::skin_application::QueueApplyFutanari(actor, selected, bcn::skin_application::FutanariSelectionMode::restore);
        if (result != bcn::SkinApplyResult::queued) return -10 - static_cast<int>(result);
        bcn::ActorRegistry::Get().SetPSQFutanariSelection(actor, selected, selected.empty() ? 3 : 2, false, {}, 0);
        return 1; // Accepted by the backend; not a claim of completed rendering.
    }
    std::int32_t RestoreFutanariSelection(RE::StaticFunctionTag*, RE::Actor* actor,
        RE::BSFixedString expected, RE::BSFixedString original, std::int32_t mode) {
        if (!FutaEligible(actor) || !IsReady(nullptr)) return -1;
        const std::string owned = expected.c_str(), baseline = original.c_str();
        if (!bcn::ActorRegistry::Get().SetPSQFutanariSelection(actor, baseline, mode, true,
                owned, owned.empty() ? 3 : 2)) return 2; // A later external/manual choice wins.
        // Clear PSQ's native addon layer even if the original addon is now absent.
        // The restored registry selection survives until that addon returns.
        const auto cleared = bcn::skin_application::QueueClearFutanari(actor,
            bcn::skin_application::FutanariSelectionMode::restore);
        if (cleared != bcn::SkinApplyResult::queued) {
            bcn::ActorRegistry::Get().SetPSQFutanariSelection(actor, owned,
                owned.empty() ? 3 : 2, true, baseline, mode);
            return -3;
        }
        if (!baseline.empty()) {
            [[maybe_unused]] const auto reapplied = bcn::skin_application::QueueApplyFutanari(actor,
                baseline, bcn::skin_application::FutanariSelectionMode::restore);
        }
        return 1;
    }
