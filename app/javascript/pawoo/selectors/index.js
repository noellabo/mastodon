import { createSelector } from 'reselect';

const getAccountRelationship = (state, id) => state.getIn(['relationships', id], null);
const getSuggestedAccountBase = (state, id) => state.getIn(['pawoo', 'suggested_accounts', id], null);

export const makeGetSuggestedAccount = () => {
  return createSelector([getSuggestedAccountBase, getAccountRelationship], (base, relationship) => {
    if (base === null) {
      return null;
    }

    return base.set('relationship', relationship);
  });
};
