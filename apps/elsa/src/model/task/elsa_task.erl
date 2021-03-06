
-module(elsa_task).

-export([new/1
       , id/1
       , set_resource/3
       , update_status/2
       , add_result/4
       , format/1]).

-include("elsa_task.hrl").

new(ServiceID) ->
  ID = elsa_hash:sha(ServiceID, elsa_date:format(elsa_date:utc())),
  #task{id = ID
      , thread_info = new_thread_info(ServiceID, no_resource, no_resource)
      , date   = elsa_date:new()
  }.

id(#task{id = ID}) -> ID.

set_resource(T = #task{thread_info=TI}, InstanceID, ThreadID) ->
  T#task{thread_info = TI#thread_info{instance_id = InstanceID
                                   , thread_id   = ThreadID
                                    }
        }.

new_thread_info(ServiceID, InstanceID, ThreadID) ->
  #thread_info{service_id  = ServiceID
             , instance_id = InstanceID
             , thread_id   = ThreadID
  }.

update_status(Task = #task{date=Date}, Status) ->
  Task#task{status = Status,
            date   = elsa_date:update(Date)
  }.

add_result(Task = #task{date=Date}, Location, Status, BodyByteSize) ->
  Task#task{result = #result{location       = Location
                           , completed_on   = elsa_date:utc()
                           , status         = Status
                           , body_byte_size = BodyByteSize
                            }
          , complete    = true
          , status      = result_ready
          , date        = elsa_date:update(Date)
          , thread_info = thread_released
  }.

format(#task{id=ID, thread_info=TI, complete=C, status=S, date=D, result=R}) ->
  [
   {<<"id">>, ID}
 , {<<"thread_info">>, format(TI)}
 , {<<"complete">>, C}
 , {<<"status">>, S}
 , {<<"date">>, elsa_date:format(D)}
  ] ++ case C of
         false -> [];
         true -> format(R)
       end;

format(#thread_info{service_id=SID, instance_id=IID, thread_id=TID}) ->
  [
   {<<"service_id">>, SID}
 , {<<"instance_Id">>, IID}
 , {<<"thread_id">>, TID}
  ];

format(#result{location=L, completed_on=CO, status=S, body_byte_size=BBS}) ->
  [
   {<<"location">>, L}
 , {<<"completed_on">>, elsa_date:format(CO)}
 , {<<"status">>, S}
 , {<<"body_byte_size">>, BBS}
  ].

