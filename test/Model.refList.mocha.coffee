Model = require '../src/Model'
should = require 'should'
{calls} = require './util'

describe 'Model.refList', ->

  it 'should support getting', ->
    model = new Model
    model.set 'items',
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
      3: {id: 3, val: 'c'}
    model.set 'map', [3, 1]
    model.refList 'list', 'items', 'map'

    model.get('list').should.eql [{id: 3, val: 'c'}, {id: 1, val: 'a'}]
    model.get('list.0').should.eql {id: 3, val: 'c'}

    # Test changing the key object
    model.set 'map', ['1', '2']
    model.get('list').should.eql [{id: 1, val: 'a'}, {id: 2, val: 'b'}]

    # Test changing referenced objects
    model.set 'items',
      1: {id: 1, val: 'x'}
      2: {id: 2, val: 'y'}
      3: {id: 3, val: 'z'}
    model.get('list').should.eql [{id: 1, val: 'x'}, {id: 2, val: 'y'}]

  it 'should support set of children', ->
    model = new Model
    model.refList 'list', 'items', 'map'

    model.set 'list.0', {id: 3, val: 'c'}
    model.set 'list.1', {id: 1, val: 'a'}
    Array.isArray(model.get('map')).should.be.true
    model.get('map').should.specEql [3, 1]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      3: {id: 3, val: 'c'}

    model.set 'list.1', {id: 1, val: 'aa'}
    model.get('map').should.specEql [3, 1]
    model.get('items').should.specEql
      1: {id: 1, val: 'aa'}
      3: {id: 3, val: 'c'}

  it 'should support del of children', ->
    model = new Model
    model.set 'items',
      1: {id: 1, val: 'a'}
      3: {id: 3, val: 'c'}
    model.set 'map', [3, 1]
    model.refList 'list', 'items', 'map'

    model.del 'list.0'
    model.get('map').should.specEql [undefined, 1]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}

  it 'should support operations on children', ->
    model = new Model
    model.set 'items',
      1: {id: 1, val: 'a'}
      3: {id: 3, val: 'c'}
    model.set 'map', [3, 1]
    model.refList 'list', 'items', 'map'

    model.set 'list.0.x', 'added'
    model.push 'list.0.arr', 7
    expected = {id: 3, val: 'c', x: 'added', arr: [7]}
    model.get('list.0').should.specEql expected
    model.get('items.3').should.specEql expected

  it 'should support push', ->
    model = new Model
    model.refList 'list', 'items', 'map'

    len = model.push 'list', {id: 3, val: 'c'}
    len.should.eql 1
    model.get('list').should.specEql [{id: 3, val: 'c'}]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [3]

    len = model.push 'list', {id: 1, val: 'a'}, {id: 2, val: 'b'}
    len.should.eql 3
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
      {id: 1, val: 'a'}
      {id: 2, val: 'b'}
    ]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [3, 1, 2]

  it 'should support unshift', ->
    model = new Model
    model.refList 'list', 'items', 'map'

    len = model.unshift 'list', {id: 3, val: 'c'}
    len.should.eql 1
    model.get('list').should.specEql [{id: 3, val: 'c'}]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [3]

    len = model.unshift 'list', {id: 1, val: 'a'}, {id: 2, val: 'b'}
    len.should.eql 3
    model.get('list').should.specEql [
      {id: 1, val: 'a'}
      {id: 2, val: 'b'}
      {id: 3, val: 'c'}
    ]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [1, 2, 3]

  it 'should support insert', ->
    model = new Model
    model.refList 'list', 'items', 'map'

    len = model.insert 'list', 0, {id: 1, val: 'a'}, {id: 2, val: 'b'}
    len.should.eql 2
    model.get('list').should.specEql [
      {id: 1, val: 'a'}
      {id: 2, val: 'b'}
    ]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
    model.get('map').should.specEql [1, 2]

    len = model.insert 'list', 1, {id: 3, val: 'c'}
    len.should.eql 3
    model.get('list').should.specEql [
      {id: 1, val: 'a'}
      {id: 3, val: 'c'}
      {id: 2, val: 'b'}
    ]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [1, 3, 2]

  it 'should support pop', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
    model.set 'map', [3, 7]
    model.refList 'list', 'items', 'map'

    key = model.pop 'list'
    # Pop returns the popped off key, not the
    # object that it referenced
    key.should.eql 7
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
    ]
    # Pop does not delete the underlying object
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
    model.get('map').should.specEql [3]

  it 'should support shift', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
    model.set 'map', [3, 7]
    model.refList 'list', 'items', 'map'

    key = model.shift 'list'
    # Shift returns the popped off key, not the
    # object that it referenced
    key.should.eql 3
    model.get('list').should.specEql [
      {id: 7, val: 'g'}
    ]
    # Shift does not delete the underlying object
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
    model.get('map').should.specEql [7]

  it 'should support remove', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.set 'map', [3, 7, 8]
    model.refList 'list', 'items', 'map'

    removed = model.remove 'list', 1
    # Remove returns the removed keys, not the
    # referenced objects
    removed.should.eql [7]
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
    ]
    # Remove does not delete the underlying objects
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [3, 8]

    removed = model.remove 'list', 0, 2
    # Remove returns the removed keys, not the
    # referenced objects
    removed.should.eql [3, 8]
    model.get('list').should.specEql []
    # Remove does not delete the underlying objects
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql []

  it 'should support move', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.set 'map', [3, 7, 8]
    model.refList 'list', 'items', 'map'

    moved = model.move 'list', 1, 0
    # Move returns the moved key, not the
    # referenced object
    moved.should.eql 7
    model.get('list').should.specEql [
      {id: 7, val: 'g'}
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
    ]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [7, 3, 8]

    moved = model.move 'list', 0, 2
    # Move returns the moved key, not the
    # referenced object
    moved.should.eql 7
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
      {id: 7, val: 'g'}
    ]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [3, 8, 7]

  it 'should support insert by id', ->
    model = new Model
    model.set 'items',
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
    model.set 'map', [1, 2]
    model.refList 'list', 'items', 'map'

    len = model.insert 'list', {id: 2}, {id: 3, val: 'c'}
    len.should.eql 3
    model.get('list').should.specEql [
      {id: 1, val: 'a'}
      {id: 3, val: 'c'}
      {id: 2, val: 'b'}
    ]
    model.get('items').should.specEql
      1: {id: 1, val: 'a'}
      2: {id: 2, val: 'b'}
      3: {id: 3, val: 'c'}
    model.get('map').should.specEql [1, 3, 2]

  it 'should support remove by id', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.set 'map', [3, 7, 8]
    model.refList 'list', 'items', 'map'

    removed = model.remove 'list', {id: 7}
    # Remove returns the removed keys, not the
    # referenced objects
    removed.should.eql [7]
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
    ]
    # Remove does not delete the underlying objects
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [3, 8]

    removed = model.remove 'list', {id: 3}, 2
    # Remove returns the removed keys, not the
    # referenced objects
    removed.should.eql [3, 8]
    model.get('list').should.specEql []
    # Remove does not delete the underlying objects
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql []

  it 'should support move by id', ->
    model = new Model
    model.set 'items',
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.set 'map', [3, 7, 8]
    model.refList 'list', 'items', 'map'

    moved = model.move 'list', {id: 7}, 0
    # Move returns the moved key, not the
    # referenced object
    moved.should.eql 7
    model.get('list').should.specEql [
      {id: 7, val: 'g'}
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
    ]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [7, 3, 8]

    moved = model.move 'list', {id: 7}, {id: 8}
    # Move returns the moved key, not the
    # referenced object
    moved.should.eql 7
    model.get('list').should.specEql [
      {id: 3, val: 'c'}
      {id: 8, val: 'h'}
      {id: 7, val: 'g'}
    ]
    model.get('items').should.specEql
      3: {id: 3, val: 'c'}
      7: {id: 7, val: 'g'}
      8: {id: 8, val: 'h'}
    model.get('map').should.specEql [3, 8, 7]
