//
//  NEO4OCSpec.m
//  
//
//  Created by Maxim Zaks on 04.06.12.
//  Copyright 2012 Besitzer. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <NEO4OC/NEO4OC.h>

SPEC_BEGIN(NEO4OCSpec)

#define START_WAIT __block int wait = 1
#define END_WAIT while(wait>0){}

describe(@"Neo4j is a graph database which can be reached through REST API", ^{
    __block NEOGraphDatabase *graph;
    
    context(@"Neo4j server is started on localhost:7474", ^{
        
        it(@"create a representation of graph databse", ^{
            graph = [[NEOGraphDatabase alloc]initWithURL:[NSURL URLWithString:@"http://localhost:7474"]];
            [graph shouldNotBeNil];
        });
        
        it(@"get information about the database", ^{
            __block NSDictionary *_info;
            [graph getInfo:^(NSDictionary *info, NEOError *error) {
                [error shouldBeNil];
                _info = info;
                NSLog(@"DB: %@", _info);
            }];
            [[expectFutureValue(_info) shouldEventually] beNonNil];
        });
        
        describe(@"A promise is a mechanism to provide data at later time and implement nonblocking behavior", ^{
            __block NEOPromise *promise;
            
            it(@"Promise has three states: 'WAITING', 'DONE', 'ERROR'", ^{
                promise = [[NEOPromise alloc]init];
                [[theValue(promise.status) should] equal:theValue(WAITING)];
                [promise setValue:@"value"];
                [[theValue(promise.status) should] equal:theValue(DONE)];
                [promise setError:[[NEOError alloc]init]];
                [[theValue(promise.status) should] equal:theValue(ERROR)];
            });
            
            it(@"Value may be set only once", ^{
                promise = [[NEOPromise alloc]init];
                [promise setValue:@"value"];
                [[theBlock(^{ [promise setValue:@"value2"]; }) should] raise];
            });
            
            pending(@"A concreet promise blocks until value is not set. Afterwards it forwards method calls to the value",^{
            });
            
            pending(@"It is posible to register callback to perform when value get set", ^{
            });
            
            pending(@"It is posible to register callback to perform when value get set", ^{
            });
            
            pending(@"An error transfers error messages and ment to be for debuging purpose only", ^{ 
            });
            
        });
        
        describe(@"A graph contains of Nodes and Edges (Relationships)", ^{
            
            describe(@"Node is an entity which can carry flat data", ^{
                __block id<NEONode> node;
                
                it(@"create a node representation with data", ^{
                    NSDictionary *data = [NSDictionary dictionaryWithObject:@"mobile.cologne" forKey:@"name"];
                    node = [graph createNodeWithData:data];
                    [[[node nodeId] should] beNonNil];
                    [[[node data] should] equal:data];
                });
                
                it(@"query for node representation by id", ^{
                    NEONodePromise *nodePromise = [graph getNodeById:node.nodeId];
                    [nodePromise wait];
                    [[[nodePromise.data objectForKey:@"name"] should] equal:@"mobile.cologne"];
                });
                
                it(@"modify data in a node", ^{
                    NEONodePromise *nodePromise = [graph getNodeById:node.nodeId];
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:nodePromise.data];
                    [data setValue:@"http://www.mobilecologne.de/" forKey:@"url"];
                    START_WAIT;
                    [nodePromise setData:data withResultHandler:^(NEOError *error) {
                        [error shouldBeNil];
                        wait = NO;
                    }];
                    END_WAIT;
                    
                    [[[nodePromise.data objectForKey:@"url"] should] equal:@"http://www.mobilecologne.de/"];
                });
                
                it(@"update stale data in a node representation", ^{
                    NSDictionary * _data = node.data;
                    [[_data objectForKey:@"url"] shouldBeNil];
                    START_WAIT;
                    [node fetchData:^(NSDictionary *data, NEOError *error){
                        [error shouldBeNil];
                        [data shouldNotBeNil];
                        wait = NO;
                    }];
                    END_WAIT;
                    [[[node.data objectForKey:@"url"] should] equal:@"http://www.mobilecologne.de/"];
                });
                
                it(@"delete node through node representation", ^{
                    START_WAIT;
                    [node deleteWithResultHandler:^(NEOError *error) {
                        [error shouldBeNil];
                        wait = NO;
                    }];
                    END_WAIT;
                    [node.nodeId shouldBeNil];
                });
            });
            
            describe(@"Relationship is a typed entity which can connect one node with another and carry flat data", ^{
                __block id<NEORelationship> rel;
                __block id<NEONode> mCologne;
                __block id<NEONode> maxim;
                __block id<NEONode> lars;
                
                beforeAll(^{
                    NSDictionary *nodeData1 = [NSDictionary dictionaryWithObject:@"name" forKey:@"mobile.cologne"];
                    mCologne = [graph createNodeWithData:nodeData1];
                    NSDictionary *nodeData2 = [NSDictionary dictionaryWithObject:@"name" forKey:@"Maxim"];
                    maxim = [graph createNodeWithData:nodeData2];
                    NSDictionary *nodeData3 = [NSDictionary dictionaryWithObject:@"name" forKey:@"Lars"];
                    lars = [graph createNodeWithData:nodeData3];
                });
                
                afterAll(^{
                    [mCologne deleteWithResultHandler:^(NEOError *error) {[error shouldBeNil];}];
                    [maxim deleteWithResultHandler:^(NEOError *error) {[error shouldBeNil];}];
                });
                
                it(@"create a relationship with data", ^{
                    NSDictionary *speaksAtData = [NSDictionary dictionaryWithObject:@"14.06.2012" forKey:@"date"];
                    rel = [maxim createRelationshipOfType:@"SPEAKS_AT" toNode:mCologne andData:speaksAtData];
                    [rel.relationshipId shouldNotBeNil];
                });
                
                it(@"query for relationship by id", ^{
                    NEORelationshipPromise *relPromise = [graph getRelationshipById:rel.relationshipId];
                    [relPromise wait];
                    [[relPromise.data should]equal:rel.data];
                });
                
                it(@"get start and end node", ^{
                    NEONodePromise *startNodePromise = [rel startNode];
                    NEONodePromise *endNodePromise = [rel endNode];
                    [NEOPromise waitForPromises:startNodePromise, endNodePromise, nil];
                    [[startNodePromise.data should]equal:maxim.data];
                    [[endNodePromise.data should]equal:mCologne.data];
                });
                
                it(@"query for all relationships of a node", ^{
                    NEORelationshipPromise *relPromise1 = [maxim createRelationshipOfType:@"KNOWS" toNode:lars andData:nil];
                    [relPromise1 wait];
                    NEORelationshipPromise *relPromise2 = [lars createRelationshipOfType:@"INVITED" toNode:maxim andData:nil];
                    [relPromise2 wait];
                    // Doesn't work because of transaction problem 
                    // [NEOPromise waitForPromises:relPromise1, relPromise2, nil];
                    START_WAIT;
                    [maxim getAllRelationshipsOfTypes:nil withResultHandler:^(NSArray *relationships, NEOError *error) {
                        [error shouldBeNil];
                        [[relationships should]haveCountOf:3];
                        wait--;
                    }];
                    END_WAIT;
                });
                
                it(@"query for outgoing relationships of a node", ^{
                    START_WAIT;
                    [maxim getOutgoingRelationshipsOfTypes:nil withResultHandler:^(NSArray *relationships, NEOError *error) {
                        [error shouldBeNil];
                        [[relationships should]haveCountOf:2];
                        wait--;
                    }];
                    END_WAIT;
                });
                
                it(@"query for incoming relationships of a node", ^{
                    START_WAIT;
                    [maxim getIncomingRelationshipsOfTypes:nil withResultHandler:^(NSArray *relationships, NEOError *error) {
                        [error shouldBeNil];
                        [[relationships should]haveCountOf:1];
                        wait--;
                    }];
                    END_WAIT;
                });
                
                it(@"modify data in a relationship", ^{
                    NEORelationshipPromise *relPromise = [graph getRelationshipById:rel.relationshipId];
                    START_WAIT;
                    [relPromise setData:[NSDictionary dictionary] withResultHandler:^(NEOError *error) {
                        [error shouldBeNil];
                        wait--;
                    }];
                    END_WAIT;
                    NSDictionary *date = [relPromise.data objectForKey:@"date"];
                    [date shouldBeNil];
                });
                
                it(@"update stale data in a node representation", ^{
                    NSDictionary *data = rel.data;
                    [[[data objectForKey:@"date"] should]equal:@"14.06.2012"];
                    START_WAIT;
                    [rel fetchData:^(NSDictionary *data, NEOError *error) {
                        [error shouldBeNil];
                        wait--;
                    }];
                    END_WAIT;
                    NSDictionary *date1 = [rel.data objectForKey:@"date"];
                    [date1 shouldBeNil];
                });
                
                it(@"delete relationships through node representation", ^{
                    START_WAIT;
                    [maxim getAllRelationshipsOfTypes:nil withResultHandler:^(NSArray *relationships, NEOError *error) {
                        [error shouldBeNil];
                        wait +=relationships.count;
                        for(id<NEORelationship> _rel in relationships){
                            __block BOOL innerWait = true;
                            [_rel deleteWithResultHandler:^(NEOError *error) {
                                [error shouldBeNil];
                                innerWait = NO;
                                wait--;
                            }];
                            while(innerWait){}
                        }
                        wait--;
                    }];
                    END_WAIT;
                });
            });
             
        });
        
        describe(@"Cypher is a graph query language", ^{
            __block NSNumber *larsId;
            __block NSNumber *dariaId;
            beforeAll(^{                    
                NEONodePromise *mobileCologne = [graph createNodeWithData:[NSDictionary dictionaryWithObject:@"mobile.cologne" forKey:@"name"]];
                
                NEONodePromise *maxim = [graph createNodeWithData:[NSDictionary dictionaryWithObject:@"Maxim Z." forKey:@"name"]];
                NEONodePromise *lars = [graph createNodeWithData:[NSDictionary dictionaryWithObject:@"Lars P." forKey:@"name"]];
                NEONodePromise *daria = [graph createNodeWithData:[NSDictionary dictionaryWithObject:@"Daria S." forKey:@"name"]];
                [[maxim createRelationshipOfType:@"SPEAK_AT" toNode:mobileCologne andData:nil] wait];
                [[lars createRelationshipOfType:@"ORGANIZE" toNode:mobileCologne andData:nil] wait];
                [[lars createRelationshipOfType:@"KNOWS" toNode:maxim andData:nil] wait];
                [[maxim createRelationshipOfType:@"FRIEND" toNode:daria andData:nil] wait];
                larsId = [NSNumber numberWithInt:lars.nodeId.intValue];
                dariaId = [NSNumber numberWithInt:daria.nodeId.intValue];
            });
            
            it(@"should find node", ^{
                NSString *query = 
                @"start n = node(*)"
                "where n.name != 'Maxim Z.'"
                "return n as node";
                
                START_WAIT;
                [graph queryCypher:query withParameters:nil andTypedResultHandler:^(NSArray *result, NEOError *error) {
                    [error shouldBeNil];
                    [[result should] haveCountOfAtLeast:1];
                    NSDictionary *result1 = [result objectAtIndex:0];
                    id<NEONode> node = [result1 objectForKey:@"node"];
                    [[[node.data objectForKey:@"name"] should] equal:@"Maxim Z."];
                    wait--;
                }];
                END_WAIT;
            });
            
            it(@"should find node wich relates to another", ^{
                NSString *query = 
                @"start n = node(*) "
                "match n-[:SPEAK_AT]->mc "
                "return n as node, mc as mobileCologne";
                
                START_WAIT;
                [graph queryCypher:query withParameters:nil andTypedResultHandler:^(NSArray *result, NEOError *error) {
                    [error shouldBeNil];
                    [[result should] haveCountOfAtLeast:1];
                    NSDictionary *result1 = [result objectAtIndex:0];
                    id<NEONode> node1 = [result1 objectForKey:@"node"];
                    [[[node1.data objectForKey:@"name"] should] equal:@"Maxim Z."];
                    
                    id<NEONode> node2 = [result1 objectForKey:@"mobileCologne"];
                    [[[node2.data objectForKey:@"name"] should] equal:@"mobile.cologne"];
                    wait--;
                }];
                END_WAIT;
            });
            
            it(@"should find path between two nodes", ^{
                NSString *query = @"start l = node({larsId}), d = node({dariaId}) match path = l -[?*]- d return path";
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:dariaId, @"dariaId", larsId, @"larsId", nil];
                NSLog(@"%@", [params description]);
                START_WAIT;
                [graph queryCypher:query withParameters:params andTypedResultHandler:^(NSArray *result, NEOError *error) {
                    [error shouldBeNil];
                    [[result should] haveCountOf:2];
                    NSLog(@"Paths from Lars to Daria %@", result);
                    wait--;
                }];
                END_WAIT;
            });
            
            it(@"should find shortest path between two nodes", ^{
                NSString *query = @"start l = node({larsId}), d = node({dariaId}) match path = shortestPath(l -[?*]- d) return path";
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:dariaId, @"dariaId", larsId, @"larsId", nil];
                START_WAIT;
                [graph queryCypher:query withParameters:params andTypedResultHandler:^(NSArray *result, NEOError *error) {
                    [error shouldBeNil];
                    [[result should] haveCountOf:1];
                    NSLog(@"Shortest paths from Lars to Daria %@", result);
                    wait--;
                }];
                END_WAIT;
            });
        });
        /*
        // TODO:
        
        describe(@"Index helps to organize and find nodes/relationships", ^{
            
        });
        
        describe(@"Traversals implement different algorithms for graph visiting", ^{
            
        });
        
        describe(@"Batch executes a list of operations in single request", ^{
            
        });
         */
    });
    
});

SPEC_END


