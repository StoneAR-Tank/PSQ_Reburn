#include "BodyChangeNG/PSQBodyBridge.h"
#include "BodyChangeNG/SkinTargetResolver.h"
#include "BodyChangeNG/ActorRegistry.h"
#include "BodyChangeNG/PSQFutaSelectionPolicy.h"
#include "BodyChangeNG/SkinApplication.h"
#include "BodyChangeNG/SkinProfiles.h"
#include "BodyChangeNG/BodyFamily.h"
#include "BodyChangeNG/FrameTasks.h"
#include "BodyChangeNG/PresetCatalog.h"
#include "BodyChangeNG/RaceMenuBodyMorph.h"
#include "BodyChangeNG/Settings.h"
#include "BodyChangeNG/SliderName.h"
#include "BodyChangeNG/TemporaryBodyPreset.h"
#include <RE/N/NativeFunction.h>
#include <RE/P/PackUnpackImpl.h>

namespace
{
    constexpr auto kClass = "BCNGPSQBridge";
    std::int32_t GetAdapterVersion(RE::StaticFunctionTag*) { return 3; }
    bool IsReady(RE::StaticFunctionTag*)
    {
        // Clear must remain available while BCNG is preparing for removal.
        return bcn::frame_tasks::Active() && bcn::racemenu::IsReady();
    }
    bool Eligible(const RE::Actor* actor)
    {
        return actor && actor == RE::PlayerCharacter::GetSingleton() && actor->GetActorBase();
    }
    std::vector<RE::BSFixedString> GetPresetIds(RE::StaticFunctionTag*, RE::Actor* actor)
    {
        std::vector<RE::BSFixedString> ids;
        if (!Eligible(actor) || !IsReady(nullptr)) return ids;
        const auto male = actor->GetActorBase()->GetSex() != RE::SEX::kFemale;
        const auto family = bcn::body_family::ResolveActor(actor);
        const auto catalog = bcn::PresetCatalog::Get().ListSnapshot();
        for (const auto& entry : *catalog) {
            if (entry.male == male && bcn::body_family::Matches(
                bcn::body_family::PresetMask(entry.family, entry.male), family))
                ids.emplace_back(entry.id.c_str());
        }
        return ids;
    }
    RE::BSFixedString GetPresetName(RE::StaticFunctionTag*, RE::BSFixedString id)
    {
        const auto preset = bcn::PresetCatalog::Get().Find(id.c_str());
        return preset ? RE::BSFixedString(preset->name.c_str()) : RE::BSFixedString{};
    }
    RE::BSFixedString FindPresetId(RE::StaticFunctionTag*, RE::Actor* actor, RE::BSFixedString name)
    {
        RE::BSFixedString found;
        if (name.empty()) return found;
        for (const auto& id : GetPresetIds(nullptr, actor)) {
            const auto preset = bcn::PresetCatalog::Get().Find(id.c_str());
            if (!preset || !bcn::slider_name::Equal{}(preset->name, name.c_str())) continue;
            if (!found.empty()) return {}; // Ambiguous names never choose another file arbitrarily.
            found = id;
        }
        return found;
    }
    std::int32_t ApplyTemporaryPreset(RE::StaticFunctionTag*, RE::Actor* actor, RE::BSFixedString id)
    {
        return bcn::racemenu::QueuePSQTemporaryPreset(actor, id.c_str(), false);
    }
    std::int32_t ClearTemporaryPreset(RE::StaticFunctionTag*, RE::Actor* actor)
    {
        return bcn::racemenu::QueuePSQTemporaryPreset(actor, {}, true);
    }
    std::int32_t RequestEquipmentMorphRefresh(RE::StaticFunctionTag*, RE::Actor* actor)
    {
        return bcn::racemenu::RequestPSQEquipmentMorphRefresh(actor);
    }
    std::int32_t GetEquipmentMorphRefreshStatus(RE::StaticFunctionTag*, RE::Actor* actor, std::int32_t request)
    {
        return bcn::racemenu::PSQEquipmentMorphRefreshStatus(actor, request);
    }
    std::int32_t GetRequestStatus(RE::StaticFunctionTag*, RE::Actor* actor, std::int32_t request)
    {
        return bcn::racemenu::PSQTemporaryRequestStatus(actor, request);
    }
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

}

namespace bcn::psq_bridge
{
    void NotifyFutanariGeometryReady(RE::Actor* actor) {
        auto* data = RE::TESDataHandler::GetSingleton();
        if (!data || !data->LookupModByName("PSQ PlayerSuccubusQuest.esm") ||
            !FutaAtlasEligible(actor) || frame_tasks::HasPreview(actor->GetFormID())) return;
        const auto route = skin_target::FindLoadedFutanariRoute(actor);
        if (!route.type || *route.type != FutanariSkinType::cbbeTrx) return;
        if (auto* events = SKSE::GetModCallbackEventSource()) {
            SKSE::ModCallbackEvent event{};
            event.eventName = "PSQ_BCNGFutaGeometryReady";
            event.sender = actor;
            events->SendEvent(&event);
        }
    }

    bool Register(RE::BSScript::IVirtualMachine* vm)
    {
        if (!vm) return false;
        vm->RegisterFunction("GetVersion", kClass, GetAdapterVersion);
        vm->RegisterFunction("GetFutanariIds", kClass, GetFutanariIds);
        vm->RegisterFunction("GetFutanariName", kClass, GetFutanariName);
        vm->RegisterFunction("GetFutanariSelectionId", kClass, GetFutanariSelectionId);
        vm->RegisterFunction("GetFutanariSelectionMode", kClass, GetFutanariSelectionMode);
        vm->RegisterFunction("RequestFutanariSkin", kClass, RequestFutanariSkin);
        vm->RegisterFunction("RestoreFutanariSelection", kClass, RestoreFutanariSelection);

        vm->RegisterFunction("RequestEquipmentMorphRefresh", kClass, RequestEquipmentMorphRefresh);
        vm->RegisterFunction("GetEquipmentMorphRefreshStatus", kClass, GetEquipmentMorphRefreshStatus);
        vm->RegisterFunction("IsReady", kClass, IsReady);
        vm->RegisterFunction("GetPresetIds", kClass, GetPresetIds);
        vm->RegisterFunction("GetPresetName", kClass, GetPresetName);
        vm->RegisterFunction("FindPresetId", kClass, FindPresetId);
        vm->RegisterFunction("ApplyTemporaryPreset", kClass, ApplyTemporaryPreset);
        vm->RegisterFunction("ClearTemporaryPreset", kClass, ClearTemporaryPreset);
        vm->RegisterFunction("GetRequestStatus", kClass, GetRequestStatus);
        return true;
    }
}
