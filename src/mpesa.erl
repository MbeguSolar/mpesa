-module(mpesa).

-export([auth/0,
         paymentrequest/3,
         c2b_registerurl/2,
         c2b_simulate/2,
         account_balance/2,
         transaction_status/2,
         reversal/2]).

auth() ->
    {ok, {Username, Password}} = application:get_env(mpesa, auth),
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/oauth/v1/generate?grant_type=client_credentials">>],
    Token = base64:encode(<<Username/binary, ":", Password/binary>>),
    shttpc:get(Path, opts(basic, Token)).

paymentrequest(Type, AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = paymentrequest_url(Type, Url),
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

paymentrequest_url(<<"b2c">>, Url) ->
    [Url, <<"/mpesa/b2c/v1/paymentrequest">>];
paymentrequest_url(<<"b2b">>, Url) ->
    [Url, <<"/mpesa/b2b/v1/paymentrequest">>].

c2b_simulate(AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/mpesa/c2b/v1/simulate">>],
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

c2b_registerurl(AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/mpesa/c2b/v1/registerurl">>],
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

account_balance(AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/mpesa/accountbalance/v1/query">>],
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

transaction_status(AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/mpesa/transactionstatus/v1/query">>],
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

reversal(AuthToken, Map) ->
    {ok, Url} = application:get_env(mpesa, url),
    Path = [Url, <<"/mpesa/transactionstatus/v1/query">>],
    Json = json:encode(Map, [maps, binary]),
    shttpc:post(Path, Json, opts(AuthToken)).

opts(undefined) ->
    #{headers => #{'Content-Type' => <<"application/json">>},
      close => true};
opts(Token) ->
    #{headers => #{'Content-Type' => <<"application/json">>,
                   'Authorization' => <<"Bearer ", Token/binary>>},
      close => true}.

opts(basic, Token) ->
    #{headers => #{'Accept' => <<"application/json">>,
                   'Authorization' => <<"Basic ", Token/binary>>},
      close => true}.
    