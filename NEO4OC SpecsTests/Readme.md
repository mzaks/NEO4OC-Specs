Neo4j is a graph database which can be reached through REST API
	
	create a representation of graph databse
	get information about the database
	
	A promise is a mechanism to provide data at later time and implement nonblocking behavior
		
		Promise has three states: "WAITING", "DONE", "ERROR"
		Value may be set only once
		A concreet promise blocks until value is not set. Afterwards it forwards method calls to the value
		It is posible to register callback to perform when value get set
		
		An error transfers error messages and ment to be for debuging purpose only
		
	A graph contains of Nodes and Edges (Relationships)
	
		Node is an entity which can carry flat data
		
			create a node representation with data
			query for node representation by id
			modify data in a node
			update stale data in a node representation
			delete node through node representation
		
		Relationship is a typed entity which can connect one node with another and carry flat data
		
			create a relationship with data
			query for relationship by id
			get start and end node 
			query for all relationships of a node
			query for outgoing relationships of a node
			query for incoming relationships of a node
			modify data in a relationship
			update stale data in a node representation
			delete relationships through node representation
			
	Cypher is a graph query language
	
	 		find node
			find node with certain data
			find node wich relates to another
			find path between two nodes
			find shortes path
			
			Path is a collection of nodes and relationships with start/end node and length
			
				path has start, end and length
				you can iterate through path nodes
				you can iterate through path relationships
			
	Index helps to organize and find nodes/relationships 
		
			create an index for nodes
			delete the index for nodes 
			create an index for relationships
			delete the index for relationships
			
			add a node to an index
			find a node in index by exact key value
			remove a node from index
			
			add a relationship to an index
			find a relationship by exact key value
			remove a relationship from index
			
	TODOs
			Unique index insertions
			Lucene index query
			Traversals
			Batch