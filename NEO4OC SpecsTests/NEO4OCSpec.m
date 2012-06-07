//
//  NEO4OCSpec.m
//  
//
//  Created by Maxim Zaks on 04.06.12.
//  Copyright 2012 Besitzer. All rights reserved.
//

#import <Kiwi/Kiwi.h>


SPEC_BEGIN(NEO4OCSpec)

describe(@"Team", ^{
    context(@"when newly created", ^{
        it(@"should have a name", ^{
            
            [[@"foo" should] equal:@"Black Hawks"];
        });
        
        xit(@"should have 11 players", ^{
            
            //[[[team should] have:11] players];
        });
    });
});

SPEC_END


