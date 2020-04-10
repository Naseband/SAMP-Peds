stock DumpPedNodesToDB(MySQL:mysql_connection, const table[] = "pednodes_dump")
{
	new Float:x, Float:y, Float:z, query[100];

	mysql_format(mysql_connection, query, sizeof query, "TRUNCATE %e;", table);
	mysql_query(mysql_connection, query, false);

	print("Dumping Ped Nodes to MYSQL table ...");

	foreach(new id : PedNode)
	{
		GetPedNodePos(id, x, y, z);

		mysql_format(mysql_connection, query, sizeof query, "INSERT INTO %e (id,x,y,z) VALUES (%d,%f,%f,%f);", table, id, x, y, z); 
		mysql_query(mysql_connection, query, false);
	}

	print("Done");
}