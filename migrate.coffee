Config = require('./config')
knex = require('knex')(Config)

Schema = require('./schema')
sequence = require('when/sequence')
sugarjs = require('sugar')

createTable = (tableName) ->
    return knex.schema.createTable(tableName, (table) ->
        column = 0
        columnKeys = Object.keys(Schema[tableName]);
        columnKeys.forEach (key) ->
            item = Schema[tableName][key]
            if (item.type is 'text' and 'fieldtype' of item)
                column = table[item.type](key, item.fieldtype)
            else if (item.type is 'string' and 'maxlength' of item)
                column = table[item.type](key, item.maxlength)
            else
                column = table[item.type](key)
            if ('nullable' of item and item.nullable is true)
                column.nullable()
            else
                column.notNullable()
            if ('primary' of item and item.primary is true)
                column.primary()
            if ('unique' of item and item.unique)
                column.unique()
            if ('unsigned' of item and item.unsigned)
                column.unsigned()
            if ('references' of item)
                column.references(item.references)
            if ('defaultTo' of item)
                column.defaultTo(item.defaultTo)

    )

dropTable = (tableName) ->
    return knex.schema.dropTable(tableName)


createTables = ->
    tables = [];
    tableNames = Object.keys(Schema);
    tables = tableNames.map (tableName) ->
        -> createTable(tableName)
    return sequence(tables);

dropTables = ->
    tables = []
    tableNames = Object.keys(Schema)
    tables = tableNames.map (tableName) ->
        -> dropTable(tableName)
    return sequence(tables);


action = process.argv[3] ? 'nothing'
if action is "createtables"
    createTables().then(->
        console.log 'Tables created!!!'
        process.exit(0)
    ).otherwise((error) ->
        throw error
    )
else if action is "droptables"
    dropTables().then(->
        console.log 'Tables droped!!!'
        process.exit(0)
    ).otherwise((error) ->
        throw error
    )
else
    process.exit(0)
