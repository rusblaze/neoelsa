

-module(v1_elsa_service_handler).

-export([init/3,
         rest_init/2,
         allowed_methods/2,
         content_types_provided/2,
         resource_exists/2,
         json_response/2]).

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Opts) ->
  {ServiceName, Request} = cowboy_req:binding(service_name, Req),
  {ok, Request, ServiceName}.

allowed_methods(Req, _State) ->
  {[<<"GET">>,<<"POST">>,<<"PUT">>,<<"DELETE">>], Req, _State}.

content_types_accepted(Req, _State) ->
  {[{<<"application/json">>, json_request}], Req, _State}.

json_request(Req, ServiceName) ->
  {Request, Body} = elsa_body:get(Req),
  Response = case elsa_body:extract(<<"service">>, Body) of
    missing -> {<<"missing">>, <<"Field version in top level">>};
    Version -> 
  elsa_service_controller:register(ServiceName, Version, Location, 



content_types_provided(Req, _State) ->
  {[{<<"application/json">>, json_response}], Req, _State}.

resource_exists(Req, ServiceName) ->
  {Exists, Versions} = case elsa_service_controller:versions(ServiceName) of
    [] -> {false, []};
    V -> {true, V}
  end,
  {Exists, Req, {ServiceName, Versions}}.

json_response(Req, {ServiceName, Versions}) ->
  V = [
        {<<"name">>, ServiceName}
      , {<<"versions">>, [ elsa_service:version_format(V) || V <- Versions]}
      ],
  {V, Req, ServiceName}.
