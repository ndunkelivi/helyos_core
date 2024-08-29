 
---
-- Name: work_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.work_processes (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    mission_queue_id bigint DEFAULT NULL,
    run_order int DEFAULT 0,
    yard_id bigint,
    yard_uid character varying,
    work_process_type_id int,
    status character varying DEFAULT 'draft',
    work_process_type_name character varying NOT NULL,
    description character varying,
    data jsonb,
    tools_uuids text[],
    agent_ids integer[] NOT NULL DEFAULT '{}',
    agent_uuids text[],
    created_at timestamp(6) without time zone DEFAULT NOW(),
    modified_at timestamp(6) without time zone DEFAULT NOW(),
    started_at timestamp(6) without time zone,
    ended_at timestamp(6) without time zone,
    sched_start_at timestamp(6) without time zone,
    sched_end_at timestamp(6) without time zone,
    wait_free_agent boolean DEFAULT true,
    process_type character varying,
    on_assignment_failure character varying DEFAULT 'DEFAULT' CHECK (on_assignment_failure IN ('DEFAULT','FAIL_MISSION', 'CONTINUE_MISSION', 'RELEASE_FAILED')),

    CONSTRAINT status_check CHECK (
        status IS NULL OR 
        status IN (
            'draft',
            'dispatched',
            'preparing resources',
            'calculating',
            'executing',
            'assignments_completed',
            'succeeded',
            'assignment_failed',
            'planning_failed',
            'failed',
            'canceling',
            'canceled'
        )
    )
);



comment on column work_processes.yard_id is '@ db id of yard where happens the work process';
comment on column work_processes.yard_uid is '@ unique identifier of yard where happens the work process; the redundancy with yard_id is necessary to improve usability of graphQL requests';
comment on column work_processes.status is '@ status of this work process: "created", "planning", "executing", "succeeded"';
comment on column work_processes.description is '@ object with request data';
comment on column work_processes.data is '@ object with request data';
comment on column work_processes.agent_ids is '@ array of agent ids participating within work process; the redundancy with agent_uuids is necessary to improve usability of graphQL requests';
comment on column work_processes.agent_uuids is '@ array of agent uuids participating within work process; the redundancy with agent_ids is necessary to improve usability of graphQL requests';
comment on column work_processes.sched_start_at is '@ specify when the work process will be processed: path planning, agent reservation, etc.';
comment on column work_processes.on_assignment_failure is '@ specify if the mission should FAIL and immediately release all agents, or should CONTINUE and release the agents in the end of the process.';

-- process_type is depracated, it will be substituted by work_process_type_name
-- description is depracated, it will be substituted by data



CREATE OR REPLACE FUNCTION public.trigger_set_timestamp_work_processes()
RETURNS TRIGGER AS 
$BODY$
BEGIN
  NEW.modified_at = NOW();
  RETURN NEW;
END;
$BODY$ 
LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_work_processes
BEFORE UPDATE ON  public.work_processes
FOR EACH ROW
EXECUTE PROCEDURE  public.trigger_set_timestamp_work_processes();




-- Breakdown work process in many services
--
-- Name: work_processe_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.work_process_type (
    id BIGSERIAL PRIMARY KEY,
    name character varying,\
    description character varying,
    num_max_agents int,
    dispatch_order jsonb,
    settings jsonb,
    extra_params jsonb,
    on_assignment_failure character varying DEFAULT 'FAIL_MISSION' CHECK (on_assignment_failure IN ('FAIL_MISSION', 'CONTINUE_MISSION', 'RELEASE_FAILED'))

);

-- extra_params is depracated

CREATE TABLE IF NOT EXISTS public.work_process_service_plan (
    id BIGSERIAL PRIMARY KEY,
    work_process_type_id bigint REFERENCES public.work_process_type(id) ON DELETE CASCADE,
    step character varying,
    request_order int,
    agent int,
    service_type  character varying,
    service_config  jsonb,
    depends_on_steps jsonb,
    is_result_assignment boolean,
    wait_dependencies_assignments boolean DEFAULT true
);


comment on column work_process_service_plan.step is '@description Label ("A", "B"..."Z") of the calculation step. Each step represents one request.';
comment on column work_process_service_plan.request_order is '@description Order of the requests sent to external service.';
comment on column work_process_service_plan.is_result_assignment is '@description If request result should be dispacthed as an assignment.';
comment on column work_process_service_plan.service_config is '@description It overides default config of external service.';
comment on column work_processes.on_assignment_failure is '@ specify if the mission should FAIL and immediately release all agents, or should CONTINUE and release the agents in the end of the process.';





-- CREATE INDEX index_assignments_on_work_process_id ON public.assignments USING btree (work_process_id);



ALTER TABLE ONLY public.work_processes
     ADD CONSTRAINT fk_wp_mission_queue FOREIGN KEY (mission_queue_id) REFERENCES public.mission_queue(id)
     ON DELETE SET NULL;



-- ALTER TABLE ONLY public.assignments
--     ADD CONSTRAINT fk_rails_79461edfd8 FOREIGN KEY (work_process_id) REFERENCES public.work_processes(id);


