/*

= metadata
== base relvar tags

This stuff is mainly used to produce some half-baked documentation/
diagrams of the database.

*/
select module('Chaos.Server.Metadata');

create language plpgsql;

/*
select new_module('chaos', 'root');
select new_module('server', 'chaos');
select new_module('metadata', 'server');
*/
create table base_relvar_metadata (
  relvar_name text unique, -- references base_relvars, fk to view
  type text check (type in('readonly', 'data', 'stack'))
);

create function set_relvar_type(vname text, vtype text) returns void as $$
begin
  insert into base_relvar_metadata (relvar_name, type)
    values (vname, vtype);
end;
$$ language plpgsql volatile;

select set_relvar_type('base_relvar_metadata', 'readonly');

/*
This view is only used in the check_code_some_tags function.
*/
/*
create view chaos_base_relvars as
  select object_name,object_type from public_database_objects
  where object_type = 'base_relvar'
  except
        select object_name,object_type from module_objects
        where module_name = 'catalog' and object_type='base_relvar';
*/
/*
part of the tests, will check all the relvars which aren't defined in
system.sql are tagged.
*/
/*
create function check_code_some_tags() returns boolean as $$
declare
  r record;
  success boolean;
begin
  success := true;
  for r in select object_name from chaos_base_relvars
    except select relvar_name from base_relvar_metadata loop
    success := false;
      raise notice
        'table % is not tagged with one of readonly, data, stack',
        r.object_name;
  end loop;
  return success;
end;
$$ language plpgsql volatile;
*/
/*

After we've loaded the sql, we can protect all the readonly relvars
from being updated again using transition constraints (see below for
how they are implemented). This might catch some programming errors.

 */
/*
create function protect_readonly_relvars() returns void as $$
declare
  r record;
begin
  for r in select relvar_name, type
           from base_relvar_metadata
           where type='readonly' loop
    perform create_update_transition_tuple_constraint(
      r.relvar_name, r.relvar_name || '_u_readonly', 'false');
    perform create_delete_transition_tuple_constraint(
      r.relvar_name, r.relvar_name || '_d_readonly', 'false');
    perform create_insert_transition_tuple_constraint(
      r.relvar_name, r.relvar_name || '_i_readonly', 'false');
    -- get module
    perform set_module_for_preceding_objects(
    (select module_name from module_objects
          where object_type = 'base_relvar'
            and object_name = r.relvar_name));
  end loop;
end;
$$ language plpgsql volatile;
*/
/*

todo: find way to enforce stack tables empty outside transaction, or
some sort of partial tests on this

*/

/*
== callback notes

add a notify on each table when it is changed. Haven't worked out how
to listen from haskell yet so is unused at the moment.

*/
/*
create function set_notifies_on_all_data_tables() returns void as $$
declare
  r record;
begin
  for r in select relvar_name from base_relvar_metadata where type='data'
  except
  select relvar_name from triggers where trigger_name like '%_changed' loop
    perform notify_on_changed(r.relvar_name);
  end loop;
end;
$$ language plpgsql volatile;

select set_module_for_preceding_objects('metadata');
*/
