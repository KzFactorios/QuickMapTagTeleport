local event_manager = {}

-- Register an event
function event_manager.register(event_name, event_id, handler)
    if not storage.qmtt.registered_events[event_name] then
        script.on_event(event_id, handler)
        storage.qmtt.registered_events[event_name] = event_id
    else
        log("Event " .. tostring(event_name) .. " is already registered.")
    end
end

-- Unregister an event
function event_manager.unregister(event_name, event_id)    
    if storage.qmtt.registered_events[event_name] then
        script.on_event(event_id, nil)
        storage.qmtt.registered_events[event_name] = nil
    else
        log("Event " .. tostring(event_name) .. " is not registered.")
    end
end

-- Check if an event is registered
function event_manager.is_registered(event_name)
    return storage.qmtt.registered_events[event_name] ~= nil
end

return event_manager
