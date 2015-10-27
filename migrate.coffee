Config = require('./config')
knex = require('knex')(Config)

Schema = require('./schema')
sequence = require('when/sequence')
_ = require('lodash')

createTable = (tableName) ->
    return knex.schema.createTable(tableName, (table) ->
        column = 0
        columnKeys = _.keys(Schema[tableName]);
        _.each(columnKeys, (key) ->
            if (Schema[tableName][key].type is 'text' && Schema[tableName][key].hasOwnProperty('fieldtype'))
                column = table[Schema[tableName][key].type](key, Schema[tableName][key].fieldtype)
            else if (Schema[tableName][key].type is 'string' && Schema[tableName][key].hasOwnProperty('maxlength'))
                column = table[Schema[tableName][key].type](key, Schema[tableName][key].maxlength)
            else
                column = table[Schema[tableName][key].type](key)
            if (Schema[tableName][key].hasOwnProperty('nullable') && Schema[tableName][key].nullable is true)
                column.nullable()
            else
                column.notNullable()
            if (Schema[tableName][key].hasOwnProperty('primary') && Schema[tableName][key].primary is true)
                column.primary()
            if (Schema[tableName][key].hasOwnProperty('unique') && Schema[tableName][key].unique)
                column.unique()
            if (Schema[tableName][key].hasOwnProperty('unsigned') && Schema[tableName][key].unsigned)
                column.unsigned()
            if (Schema[tableName][key].hasOwnProperty('references'))
                column.references(Schema[tableName][key].references)
            if (Schema[tableName][key].hasOwnProperty('defaultTo'))
                column.defaultTo(Schema[tableName][key].defaultTo)
        )
    )

dropTable = (tableName) ->
    return knex.schema.dropTable(tableName)


createTables = ->
    tables = [];
    tableNames = _.keys(Schema);
    tables = _.map(tableNames, (tableName) ->
        return ->
            return createTable(tableName)
    )
    return sequence(tables);

dropTables = ->
    tables = []
    tableNames = _.keys(Schema)
    tables = _.map(tableNames, (tableName) ->
        return ->
            return dropTable(tableName)
    )
    return sequence(tables);


action = "nothing"
action = process.argv[3] if process.argv[3]?

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
