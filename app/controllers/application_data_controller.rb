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
    where tg.\"key\" in ('#{keys.join("','")}')
    and tg.\"active\" = true
),
t as (
    select t.\"id\" as id, t.\"topic_group_id\" as _id, t.\"order\" as o, t.\"active\" as a, t.\"displayed_name\" as n, t.\"updated_at\" as u
    from topics t, tg tg
    where t.\"topic_group_id\" = tg.\"id\"
    and t.\"active\" = true
),
c as (
    select c.\"id\" as id, c.\"topic_id\" as _id, c.\"order\" as o, c.\"active\" as a, c.\"displayed_name\" as n, c.\"updated_at\" as u
    from categories c, t t
    where c.\"topic_id\" = t.\"id\"
    and c.\"active\" = true
),
v as (
    select v.\"id\" as id, v.\"category_id\" as _id, v.\"active\" as a, v.\"name\" as n, v.\"old_price\" as op, v.\"new_price\" as np,
    v.\"discount\" as ds, '/content/v/' || v.\"id\" || '/thumb/#{quality}/'  || v.\"file_key\" || '.jpg' as t,
    v.\"url\" as l, v.\"updated_at\" as u
    from values v, c c
    where v.\"category_id\" = c.\"id\"
    and v.\"active\" = true
),
d as (
    select d.\"id\" as id, d.\"value_id\" as _id, d.\"order\" as o, d.\"active\" as a, coalesce(d.\"caption\", '') as c,
    d.\"text\" as t, d.\"updated_at\" as u
    from descriptions d, v v
    where d.\"value_id\" = v.\"id\"
    and d.\"active\" = true
),
p as (
    select p.\"id\" as id, p.\"value_id\" as _id, p.\"order\" as o, p.\"active\" as a, 
    '/content/v/' || p.\"value_id\" || '/promo/#{quality}/' || p.\"id\" || p.\"file_key\" || '.jpg' as l, p.\"updated_at\" as u
    from promos p, v v
    where p.\"value_id\" = v.\"id\"
    and p.\"active\" = true
),
ad as (
    select (select coalesce(json_agg(row_to_json((tg))), '[]') from tg) as g,
    (select coalesce(json_agg(row_to_json(t)), '[]') from t) as t,
    (select coalesce(json_agg(row_to_json(c)), '[]') from c) as c,
    (select coalesce(json_agg(row_to_json(v)), '[]') from v) as v,
    (select coalesce(json_agg(row_to_json(d)), '[]') from d) as d,
    (select coalesce(json_agg(row_to_json(p)), '[]') from p) as p
)
select row_to_json(ad) as d from ad;"
  end

  def delta_lighting_query(keys, date, quality)
"set work_mem = '16MB';
with tg as (
    select tg.\"id\" as id, tg.\"order\" as o, tg.\"active\" as a, tg.\"key\" as k, tg.\"name\" as n, tg.\"updated_at\" as u
    from topic_groups tg
    where tg.\"key\" in ('#{keys.join("','")}')
    and tg.\"active\" = true
    union
    select tg.\"id\" as id, 0 as o, tg.\"active\" as a, '' as k, '' as n, tg.\"updated_at\" as u
    from topic_groups tg
    where tg.\"key\" in ('#{keys.join("','")}')
    and tg.\"active\" = false
),
t as (
    select t.\"id\" as id, t.\"topic_group_id\" as _id, t.\"order\" as o, t.\"active\" as a, t.\"displayed_name\" as n, t.\"updated_at\" as u
    from tg tg, topics t
    where tg.\"a\" = true
    and t.\"topic_group_id\" = tg.\"id\"
    and t.\"active\" = true
    union
    select t.\"id\" as id, 0 as _id, 0 as o, t.\"active\" as a, '' as n, t.\"updated_at\" as u
    from tg tg, topics t
    where tg.\"a\" = true
    and t.\"topic_group_id\" = tg.\"id\"
    and t.\"active\" = false
),
c as (
    select c.\"id\" as id, c.\"topic_id\" as _id, c.\"order\" as o, c.\"active\" as a, c.\"displayed_name\" as n, c.\"updated_at\" as u
    from t t, categories c
    where t.\"a\" = true
    and c.\"topic_id\" = t.\"id\"
    and c.\"active\" = true
    union
    select c.\"id\" as id, 0 as _id, 0 as o, c.\"active\" as a, '' as n, c.\"updated_at\" as u
    from t t, categories c
    where t.\"a\" = true
    and c.\"topic_id\" = t.\"id\"
    and c.\"active\" = false
),
v as (
    select v.\"id\" as id, v.\"category_id\" as _id, v.\"active\" as a, v.\"name\" as n, v.\"old_price\" as op, v.\"new_price\" as np,
    v.\"discount\" as ds, '/content/v/' || v.\"id\" || '/thumb/#{quality}/'  || v.\"file_key\" || '.jpg' as t,
    v.\"url\" as l, v.\"updated_at\" as u
    from c c, values v
    where c.\"a\" = true
    and v.\"category_id\" = c.\"id\"
    and v.\"active\" = true
    union
    select v.\"id\" as id, 0 as _id, v.\"active\" as a, '' as n, 0 as op, 0 as np,
    0 as ds, '' as t,
    '' as l, v.\"updated_at\" as u
    from c c, values v
    where c.\"a\" = true
    and v.\"category_id\" = c.\"id\"
    and v.\"active\" = false
),
d as (
    select d.\"id\" as id, d.\"value_id\" as _id, d.\"order\" as o, d.\"active\" as a, coalesce(d.\"caption\", '') as c,
    d.\"text\" as t, d.\"updated_at\" as u
    from v v, descriptions d
    where v.\"a\" = true
    and d.\"value_id\" = v.\"id\"
    and d.\"active\" = true
    union
    select d.\"id\" as id, 0 as _id, 0 as o, d.\"active\" as a, '' as c,
    '' as t, false as r, false as b, d.\"updated_at\" as u
    from v v, descriptions d
    where v.\"a\" = true
    and d.\"value_id\" = v.\"id\"
    and d.\"active\" = false
),
p as (
    select p.\"id\" as id, p.\"value_id\" as _id, p.\"order\" as o, p.\"active\" as a, 
    '/content/v/' || p.\"value_id\" || '/promo/#{quality}/' || p.\"id\" || p.\"file_key\" || '.jpg' as l,
    p.\"updated_at\" as u
    from v v, promos p
    where v.\"a\" = true
    and p.\"value_id\" = v.\"id\"
    and p.\"active\" = true
    union
    select p.\"id\" as id, 0 as _id, 0 as o, p.\"active\" as a,
    '' as l,
    p.\"updated_at\" as u
    from v v, promos p
    where v.\"a\" = true
    and p.\"value_id\" = v.\"id\"
    and p.\"active\" = false
),
ad as (
    select
    (select coalesce(json_agg(row_to_json(tg)), '[]') from tg where tg.\"u\" > '#{date}') as g,
    (select coalesce(json_agg(row_to_json(t)), '[]') from t where t.\"u\" > '#{date}') as t,
    (select coalesce(json_agg(row_to_json(c)), '[]') from c where c.\"u\" > '#{date}') as c,
    (select coalesce(json_agg(row_to_json(v)), '[]') from v where v.\"u\" > '#{date}') as v,
    (select coalesce(json_agg(row_to_json(d)), '[]') from d where d.\"u\" > '#{date}') as d,
    (select coalesce(json_agg(row_to_json(p)), '[]') from p where p.\"u\" > '#{date}') as p
)
select row_to_json(ad) as d from ad;"
  end

  def normalize_date_time(datetime)
    result = Time.parse datetime
    result = (result - 10.minutes).floor(1.hours) + 10.minutes
    result.utc
  end

end