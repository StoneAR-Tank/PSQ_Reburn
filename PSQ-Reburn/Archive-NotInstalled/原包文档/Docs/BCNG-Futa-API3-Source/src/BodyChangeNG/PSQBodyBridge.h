#pragma once

namespace RE { class Actor; }
namespace RE::BSScript { class IVirtualMachine; }
namespace bcn::psq_bridge
{
    void NotifyFutanariGeometryReady(RE::Actor* actor);
    [[nodiscard]] bool Register(RE::BSScript::IVirtualMachine* a_vm);
}
