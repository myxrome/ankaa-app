class ApplicationDataController < ActionController::Base

  def initial
    ActiveRecord::Base.establish_connection
    result = ActiveRecord::Base.connection.execute(
        init_lighting_query(params[:k],
                            params[:q]))
    render json: result.first['d'].to_s
  end

  def delta
    ActiveRecord::Base.establish_connection
    result = ActiveRecord::Base.connection.execute(
        delta_lighting_query(params[:k],
                             normalize_date_time(params[:u]).to_s(:db),
                             params[:q]))
    render json: result.first['d'].to_s
  end

  private
  def init_lighting_query(keys, quality)
    "set work_mem = '16MB';
with tg as (
    select tg.\"id\" as id, tg.\"order\" as o, tg.\"active\" as a, tg.\"key\" as k, tg.\"name\" as n, tg.\"updated_at\" as u
    from topic_groups tg
    where tg.\"key\" in ('#{keys.join(',')}')
    and tg.\"active\" = true
),
t as (
    select t.\"id\" as id, t.\"topic_group_id\" as _id, t.\"order\" as o, t.\"active\" as a, t.\"name\" as n, t.\"updated_at\" as u
    from topics t, tg tg
    where t.\"topic_group_id\" = tg.\"id\"
    and t.\"active\" = true
),
c as (
    select c.\"id\" as id, c.\"topic_id\" as _id, c.\"order\" as o, c.\"active\" as a, c.\"name\" as n, c.\"updated_at\" as u
    from categories c, t t
    where c.\"topic_id\" = t.\"id\"
    and c.\"active\" = true
),
_v as (
    select v.\"id\" as id, v.\"category_id\" as _id, v.\"active\" as a, v.\"name\" as n, v.\"old_price\" as op, v.\"new_price\" as np,
    v.\"discount\" as ds,
    (select '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || 'thumb.jpg'
    from promos p
    where p.\"value_id\" = v.\"id\"
    and p.\"order\" = 1) as t,
    v.\"url\" as l, v.\"updated_at\" as u
    from values v, c c
    where v.\"category_id\" = c.\"id\"
    and v.\"active\" = true
),
d as (
    select d.\"id\" as id, d.\"value_id\" as _id, d.\"order\" as o,
    coalesce((select dt.\"caption\" from description_templates dt where dt.id = d.description_template_id), '') as c,
    d.\"text\" as t, coalesce(d.\"red\", false) as r, coalesce(d.\"bold\", false) as b, d.\"updated_at\" as u
    from descriptions d, _v v
    where d.\"value_id\" = v.\"id\"
),
p as (
    select p.\"id\" as id, p.\"value_id\" as _id, p.\"order\" as o,
    '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || '#{quality}' || '.jpg' as l,
    p.\"updated_at\" as u
    from promos p, _v v
    where p.\"value_id\" = v.\"id\"
),
v as (
    select _v.*,
    ( select coalesce(json_agg(row_to_json((d))), '[]') from d d where d.\"_id\" = _v.\"id\") as d,
    ( select coalesce(json_agg(row_to_json((p))), '[]') from p p where p.\"_id\" = _v.\"id\") as p
    from _v _v
),
ad as (
    select (select coalesce(json_agg(row_to_json((tg))), '[]') from tg) as g,
    (select coalesce(json_agg(row_to_json((t))), '[]') from t) as t,
    (select coalesce(json_agg(row_to_json((c))), '[]') from c) as c,
    (select coalesce(json_agg(row_to_json((v))), '[]') from v) as v
)
select row_to_json(ad) as d from ad;"
  end

  def delta_lighting_query(keys, date, quality)
    "set work_mem = '16MB';
with tg as (
    select tg.\"id\" as id, tg.\"order\" as o, tg.\"active\" as a, tg.\"key\" as k, tg.\"name\" as n, tg.\"updated_at\" as u
    from topic_groups tg
    where tg.\"key\" in ('#{keys.join(',')}')
),
t as (
    select t.\"id\" as id, t.\"topic_group_id\" as _id, t.\"order\" as o, t.\"active\" as a, t.\"name\" as n, t.\"updated_at\" as u
    from topics t, tg tg
    where t.\"topic_group_id\" = tg.\"id\"
),
c as (
    select c.\"id\" as id, c.\"topic_id\" as _id, c.\"order\" as o, c.\"active\" as a, c.\"name\" as n, c.\"updated_at\" as u
    from categories c, t t
    where c.\"topic_id\" = t.\"id\"
),
_v as (
    select v.\"id\" as id, v.\"category_id\" as _id, v.\"active\" as a, v.\"name\" as n, v.\"old_price\" as op, v.\"new_price\" as np,
    v.\"discount\" as ds,
    (select '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || 'thumb.jpg'
    from promos p
    where p.\"value_id\" = v.\"id\"
    and p.\"order\" = 1) as t,
    v.\"url\" as l, v.\"updated_at\" as u
    from values v, c c
    where v.\"category_id\" = c.\"id\"
    and v.\"updated_at\" > '#{date}'
),
d as (
    select d.\"id\" as id, d.\"value_id\" as _id, d.\"order\" as o,
    coalesce((select dt.\"caption\" from description_templates dt where dt.id = d.description_template_id), '') as c,
    d.\"text\" as t, coalesce(d.\"red\", false) as r, coalesce(d.\"bold\", false) as b, d.\"updated_at\" as u
    from descriptions d, _v v
    where d.\"value_id\" = v.\"id\"
    and v.\"a\" = true
),
p as (
    select p.\"id\" as id, p.\"value_id\" as _id, p.\"order\" as o,
    '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || '#{quality}' || '.jpg' as l,
    p.\"updated_at\" as u
    from promos p, _v v
    where p.\"value_id\" = v.\"id\"
    and v.\"a\" = true
),
v as (
    select _v.*,
    ( select coalesce(json_agg(row_to_json((d))), '[]') from d d where d.\"_id\" = _v.\"id\") as d,
    ( select coalesce(json_agg(row_to_json((p))), '[]') from p p where p.\"_id\" = _v.\"id\") as p
    from _v _v
),
ad as (
    select (select coalesce(json_agg(row_to_json((tg))), '[]') from tg where tg.\"u\" > '#{date}') as g,
    (select coalesce(json_agg(row_to_json((t))), '[]') from t where t.\"u\" > '#{date}') as t,
    (select coalesce(json_agg(row_to_json((c))), '[]') from c where c.\"u\" > '#{date}') as c,
    (select coalesce(json_agg(row_to_json((v))), '[]') from v) as v
)
select row_to_json(ad) as d from ad;"
  end

  def normalize_date_time(datetime)
    result = Time.parse datetime
    result = result.floor(3.hours) + 10.minutes
    result.utc
  end

end