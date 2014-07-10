-module(bst).
-behaviour(gen_server).
-export([start_link/0, start_link/1, insert/1, search/1, traverse/1]).
-export([init/1, code_change/3, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-record(bstNode, {key = nil, value = nil, leftNode = nil, rightNode = nil}).
-define(Name, bst).

init(BstNode) -> {ok,BstNode}.
code_change(_, _, _) -> ok.

handle_call(Key, _From, BstNode) ->
  {reply, search_for_node(Key, BstNode), BstNode}.

search_for_node(Key, BstNode) ->
  if BstNode#bstNode.key =:= Key ->
      {BstNode#bstNode.key, BstNode#bstNode.value};
    BstNode#bstNode.key < Key ->
      search_for_node(Key, BstNode#bstNode.rightNode);
    BstNode#bstNode.key > Key -> search_for_node(Key, BstNode#bstNode.leftNode);
    true -> {notfound, nil}
  end.

handle_cast({Key, Value}, BstNode) ->
  if BstNode#bstNode.key =:= nil ->
      {noreply, BstNode#bstNode{key = Key, value = Value}};
    true -> {noreply, insert_at_node({Key, Value}, BstNode)}
  end.

insert_at_node({Key, Value}, BstNode) ->
  if BstNode#bstNode.key =:= Key ->
      BstNode#bstNode{key = Key, value = Value};
    BstNode#bstNode.key > Key ->
      if BstNode#bstNode.leftNode =:= nil ->
          BstNode#bstNode{leftNode = #bstNode{key = Key, value = Value}};
        true -> BstNode#bstNode{leftNode = insert_at_node({Key, Value}, BstNode#bstNode.leftNode)}
      end;
    true ->
      if BstNode#bstNode.rightNode =:= nil ->
          BstNode#bstNode{rightNode = #bstNode{key = Key, value = Value}};
        true -> BstNode#bstNode{rightNode = insert_at_node({Key, Value}, BstNode#bstNode.rightNode)}
      end
  end.

handle_info(_, _) -> ok.
terminate(_, _) -> ok.

start_link() ->
  start_link(#bstNode{}).

start_link(BstNode) ->
  gen_server:start_link({local, ?Name}, ?Name, BstNode, [{timeout, 100}]).

-spec insert({number(), any()}) -> ok.
insert(Value) ->
  gen_server:cast(?Name, Value).

-spec search(number()) -> {number() | atom(), any()}.
search(Value) ->
  gen_server:call(?Name, Value).

-spec traverse(fun()) -> any().
traverse(F) ->
  BstNode = sys:get_state(?Name),
  traverse(BstNode, F).

traverse(BstNode, F) ->
  if BstNode =:= nil -> ok;
    true ->
      traverse(BstNode#bstNode.leftNode, F),
      F({BstNode#bstNode.key, BstNode#bstNode.value}),
      traverse(BstNode#bstNode.rightNode, F)
  end.
